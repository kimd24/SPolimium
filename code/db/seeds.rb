# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'json'
require 'open-uri'
require 'pp'
require 'net/http'
require 'httparty'
nameToProID = {}

Legislator.delete_all if Rails.env.development?

proPubListSURI = URI.parse("https://api.propublica.org/congress/v1/115/senate/members.json")
proPubListHURI = URI.parse("https://api.propublica.org/congress/v1/115/house/members.json")
listRequest = Net::HTTP::Get.new(proPubListSURI, 'Content-Type' => 'application/json')
listRequest["X-Api-Key"] = ENV['proPublicaKey']

req_options = {
  use_ssl: proPubListSURI.scheme == "https",
}

Net::HTTP.start(proPubListSURI.hostname, proPubListSURI.port, req_options) do |http|
  senators = http.request(listRequest)
  senatorsJSON = JSON.parse(senators.body)
  senatorsJSON["results"][0]["members"].each do |senator|
    nameToProID[senator["first_name"] + " " + senator["last_name"]] = senator["id"]
  end
end

listRequest = Net::HTTP::Get.new(proPubListHURI, 'Content-Type' => 'application/json')
listRequest["X-Api-Key"] = ENV['proPublicaKey']

req_options = {
  use_ssl: proPubListHURI.scheme == "https",
}

Net::HTTP.start(proPubListHURI.hostname, proPubListHURI.port, req_options) do |http|
  reps = http.request(listRequest)
  repsJSON = JSON.parse(reps.body)
  repsJSON["results"][0]["members"].each do |rep|
    nameToProID[rep["first_name"] + " " + rep["last_name"]] = rep["id"]
  end
end

LegislatorsURL = "https://theunitedstates.io/congress-legislators/legislators-current.json"

legislators = JSON.parse(open(LegislatorsURL).read)
legislators.each do |legislator|
  unless nameToProID[legislator["name"]["first"] + " " + legislator["name"]["last"]] == nil
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
    #unless legislator["id"]["opensecrets"] == nil 
    candSummary = HTTParty.get('https://www.opensecrets.org/api/?method=candSummary&cid=' + legislator["id"]["opensecrets"] + '&apikey=' + ENV['openSecretsKey'] + '&output=json')
    #candSummary = JSON.parse(open(candSummaryURL).read)
    candSummaryJSON = JSON.parse(candSummary.body)
    candContrib = HTTParty.get('https://www.opensecrets.org/api/?method=candContrib&cid=' + legislator["id"]["opensecrets"] + '&apikey=' + ENV['openSecretsKey'] + '&output=json')
    #contribJSON = JSON.parse(open(candContrib).read)
    contribJSON = JSON.parse(candContrib.body)
    candIndustry = HTTParty.get('https://www.opensecrets.org/api/?method=candIndustry&cid=' + legislator["id"]["opensecrets"] + '&apikey=' + ENV['openSecretsKey'])
    #end
    puts legislator["terms"][legislator["terms"].length - 1]["contact_form"] 
    puts candSummaryJSON["response"]["summary"]["@attributes"]["cycle"]
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
      candIndustries: candIndustry.body,
      positions: positionsJSON, 
      contact_form: legislator["terms"][legislator["terms"].length - 1]["contact_form"], 
      address: legislator["terms"][legislator["terms"].length - 1]["address"],
      phone: legislator["terms"][legislator["terms"].length - 1]["phone"])
  end
end
