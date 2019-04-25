
require 'json'
require 'open-uri'
require 'pp'
require 'net/http'
require 'httparty'

url = "https://raw.githubusercontent.com/maltyeva/iba-cocktails/master/recipes.json"
Cocktail.delete_all if Rails.env.development?
cocktails = JSON.parse(open(url).read)

cocktails.each do |cocktail|
  Cocktail.create!(name: cocktail["name"], glass: cocktail["glass"], ingredients: cocktail["ingredients"], preparation: cocktail["preparation"])
end
#hash for getting proPublicaID for a legislator
nameToProID = {}

#delete existing data
Legislator.delete_all if Rails.env.development?

#Senators only for now
#URI for executing curl
proPubListSURI = URI.parse("https://api.propublica.org/congress/v1/115/senate/members.json")
#proPubListHURI = URI.parse("https://api.propublica.org/congress/v1/115/house/members.json")
listRequest = Net::HTTP::Get.new(proPubListSURI, 'Content-Type' => 'application/json')
listRequest["X-Api-Key"] = ENV['proPublicaKey']

#use ssl
req_options = {
  use_ssl: proPubListSURI.scheme == "https",
}

#turn string into json and populate nameToProID
Net::HTTP.start(proPubListSURI.hostname, proPubListSURI.port, req_options) do |http|
  senators = http.request(listRequest)
  senatorsJSON = JSON.parse(senators.body)
  senatorsJSON["results"][0]["members"].each do |senator|
    nameToProID[senator["first_name"] + " " + senator["last_name"]] = senator["id"]
  end
end

#new request
#listRequest = Net::HTTP::Get.new(proPubListHURI, 'Content-Type' => 'application/json')
#listRequest["X-Api-Key"] = ENV['proPublicaKey']

#req_options = {
 # use_ssl: proPubListHURI.scheme == "https",
#}

# turn string into json and populate nameToProID
=begin
Net::HTTP.start(proPubListHURI.hostname, proPubListHURI.port, req_options) do |http|
  reps = http.request(listRequest)
  repsJSON = JSON.parse(reps.body)
  repsJSON["results"][0]["members"].each do |rep|
    nameToProID[rep["first_name"] + " " + rep["last_name"]] = rep["id"]
  end
end
=end

LegislatorsURL = "https://theunitedstates.io/congress-legislators/legislators-current.json"
legislators = JSON.parse(open(LegislatorsURL).read)

i = 0
legislators.each do |legislator|
  if nameToProID.has_key?(legislator["name"]["first"] + " " + legislator["name"]["last"])
    puts i
    i = i + 1
    positionURI = URI.parse("https://api.propublica.org/congress/v1/members/" + nameToProID[legislator["name"]["first"] + " " + legislator["name"]["last"]] + "/votes.json")
    voteRequest = Net::HTTP::Get.new(positionURI)
    voteRequest["X-Api-Key"] = ENV['proPublicaKey']

    req_options = {
      use_ssl: positionURI.scheme == "https",
    }

    positions = Net::HTTP.start(positionURI.hostname, positionURI.port, req_options) do |http|
      http.request(voteRequest)   
    end
    positionsJSON = JSON.parse(positions.body)
    
    candSummary = {}
    contribJSON = {}    
    industryJSON = {}

    unless legislator["id"]["opensecrets"] == nil
      candSummary = HTTParty.get('https://www.opensecrets.org/api/?method=candSummary&cid=' + legislator["id"]["opensecrets"] + '&apikey=' + ENV['openSecretsKey'] + '&output=json')
      candSummaryJSON = JSON.parse(candSummary.body)

      candContrib = HTTParty.get('https://www.opensecrets.org/api/?method=candContrib&cid=' + legislator["id"]["opensecrets"] + '&apikey=' + ENV['openSecretsKey'] + '&output=json')
      contribJSON = JSON.parse(candContrib.body)

      candIndustry = HTTParty.get('https://www.opensecrets.org/api/?method=candIndustry&cid=' + legislator["id"]["opensecrets"] + '&apikey=' + ENV['openSecretsKey'])
      industryJSON = Hash.from_xml(candIndustry.body).to_json
    end

    Legislator.create!(name: legislator["name"]["first"] + " " + legislator["name"]["last"],
      title: legislator["terms"][legislator["terms"].length - 1]["type"],
      birthday: legislator["bio"]["birthday"], gender: legislator["bio"]["gender"],
      cycle: candSummaryJSON["response"]["summary"]["@attributes"]["cycle"],
      state: candSummaryJSON["response"]["summary"]["@attributes"]["state"],
      party: candSummaryJSON["response"]["summary"]["@attributes"]["party"],
      total_receipts: candSummaryJSON["response"]["summary"]["@attributes"]["total"],
      spent: candSummaryJSON["response"]["summary"]["@attributes"]["spent"],
      cash_on_hand: candSummaryJSON["response"]["summary"]["@attributes"]["cash_on_hand"],
      debt: candSummaryJSON["response"]["summary"]["@attributes"]["debt"],
      sourceOpenSecrets: candSummaryJSON["response"]["summary"]["@attributes"]["source"],
      candContributors: contribJSON,
      candIndustries: industryJSON,
      positions: positionsJSON, 
      contact_form: legislator["terms"][legislator["terms"].length - 1]["contact_form"], 
      address: legislator["terms"][legislator["terms"].length - 1]["address"],
      phone: legislator["terms"][legislator["terms"].length - 1]["phone"])
  end
end
