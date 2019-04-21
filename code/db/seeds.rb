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
require 'uri'

proPubListURI = URI.parse("https://api.propublica.org/congress/v1/115/senate/members.json")
listRequest = Net::HTTP::Get.new(proPubListURI)
listRequest["X-Api-Key"] = ENV['proPublicaKey']

req_options = {
  use_ssl: proPubListURI.scheme == "https",
}

response = Net::HTTP.start(proPubListURI.hostname, proPubListURI.port, req_options) do |http|
  http.request(listRequest)
end

puts response.code
puts response.body
=begin
LegislatorsURL = "https://theunitedstates.io/congress-legislators/legislators-current.json"
Legislator.delete_all if Rails.env.development?

legislators = JSON.parse(open(LegislatorsURL).read)
legislators.each do |legislator|
  candSummaryURL = "http://www.opensecrets.org/api/?method=candSummary&cid=" + legislator["id"]["opensecrets"] + "&apikey=" + ENV['openSecretsKey'] + "&output=json"
  candContrib = "http://www.opensecrets.org/api/?method=candContrib&cid=" + legislator["id"]["opensecrets"] + "&apikey=" + ENV['openSecretsKey'] + "&output=json"
  candIndustry = "http://www.opensecrets.org/api/?method=candIndustry&cid=" + legislator["id"]["opensecrets"] + "&apikey=" + ENV['openSecretsKey'] + "&output=json"
  candSummary = JSON.parse(open(candSummaryURL).read)
  Legislator.create!(name: legislator["name"]["first"] + " " + legislator["name"]["last"], birthday: legislator["bio"]["birthday"], gender: legislator["bio"]["gender"], cycle: candSummary["response"]["summary"]["@attributes"]["cycle"], state: candSummary["response"]["summary"]["@attributes"]["state"], party: candSummary["response"]["summary"]["@attributes"]["party"], total_receipts: candSummary["response"]["summary"]["@attributes"]["total"], spent: candSummary["response"]["summary"]["@attributes"]["spent"], cash_on_hand: candSummary["response"]["summary"]["@attributes"]["cash_on_hand"], debt: candSummary["response"]["summary"]["@attributes"]["debt"], sourceOpenSecrets: candSummary["response"]["summary"]["@attributes"]["source"], candContributors: candContrib, candIndustries: candIndustry)

end
=end
