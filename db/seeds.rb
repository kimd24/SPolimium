# frozen_string_literal: true

# Project name: Polimium
# Description: Search engine for politicans
# Filename: seeds.rb
# Description: populates the database by accessing external APIs
# Last modified on: 4/25/2019

require_relative 'helper.rb'
require 'json'
require 'open-uri'
require 'pp'
require 'net/http'
require 'httparty'
require 'http'

# hash for getting proPublicaID for a legislator
nameToProID = {}

# delete existing data
Legislator.delete_all if Rails.env.development?

# Senators only for now
# URI for executing curl
proPubListSURI = URI.parse('https://api.propublica.org/congress/v1/115/senate/members.json')
# proPubListHURI = URI.parse("https://api.propublica.org/congress/v1/115/house/members.json")
listRequest = Net::HTTP::Get.new(proPubListSURI, 'Content-Type' => 'application/json')
listRequest['X-Api-Key'] = Rails.application.credentials.dig(:pro_publica)

# use ssl
req_options = {
  use_ssl: proPubListSURI.scheme == 'https'
}

# turn string into json and populate nameToProID
Net::HTTP.start(proPubListSURI.hostname, proPubListSURI.port, req_options) do |http|
  senators = http.request(listRequest)
  senatorsJSON = JSON.parse(senators.body)
  senatorsJSON['results'][0]['members'].each do |senator|
    nameToProID[senator['first_name'] + ' ' + senator['last_name']] = senator['id']
  end
end

# This part has been omitted due to API call limits
# new request
# listRequest = Net::HTTP::Get.new(proPubListHURI, 'Content-Type' => 'application/json')
# listRequest["X-Api-Key"] = ENV['proPublicaKey']

# req_options = {
# use_ssl: proPubListHURI.scheme == "https",
# }

# turn string into json and populate nameToProID
# Net::HTTP.start(proPubListHURI.hostname, proPubListHURI.port, req_options) do |http|
#   reps = http.request(listRequest)
#   repsJSON = JSON.parse(reps.body)
#   repsJSON["results"][0]["members"].each do |rep|
#     nameToProID[rep["first_name"] + " " + rep["last_name"]] = rep["id"]
#   end
# end

# Get names of legislators
LegislatorsURL = 'https://theunitedstates.io/congress-legislators/legislators-current.json'
legislators = JSON.parse(open(LegislatorsURL).read)

# Use basic legislator profiles to create legislator records with additional data
i = 0
legislators.each do |legislator|
  next unless nameToProID.key?(legislator['name']['first'] + ' ' + legislator['name']['last'])

  # track progress of seeding
  puts i
  i += 1

  # curl to ruby
  positionURI = URI.parse('https://api.propublica.org/congress/v1/members/' + nameToProID[legislator['name']['first'] + ' ' + legislator['name']['last']] + '/votes.json')
  voteRequest = Net::HTTP::Get.new(positionURI)
  voteRequest['X-Api-Key'] = Rails.application.credentials.dig(:pro_publica)

  req_options = {
    use_ssl: positionURI.scheme == 'https'
  }

  positions = Net::HTTP.start(positionURI.hostname, positionURI.port, req_options) do |http|
    http.request(voteRequest)
  end
  positionsJSON = JSON.parse(positions.body)

  # default jsons/hashes
  candSummary = {}
  contribJSON = {}
  industryJSON = {}

  # convert responses to hashes
  next if legislator['id']['opensecrets'].nil?

  puts ('https://www.opensecrets.org/api/?method=candSummary&cid=' + legislator['id']['opensecrets'] + '&apikey=' + Rails.application.credentials.dig(:open_secrets) + '&output=json')
  candSummary = HTTP.get('https://www.opensecrets.org/api/?method=candSummary&cid=' + legislator['id']['opensecrets'] + '&apikey=' + Rails.application.credentials.dig(:open_secrets) + '&output=json')
  puts candSummary
  candSummaryJSON = JSON.parse(candSummary.body)

  candContrib = HTTP.get('https://www.opensecrets.org/api/?method=candContrib&cid=' + legislator['id']['opensecrets'] + '&apikey=' + Rails.application.credentials.dig(:open_secrets) + '&output=json')
  contribJSON = JSON.parse(candContrib.body)

  candIndustry = HTTP.get('https://www.opensecrets.org/api/?method=candIndustry&cid=' + legislator['id']['opensecrets'] + '&apikey=' + Rails.application.credentials.dig(:open_secrets))
  industryJSON = Hash.from_xml(candIndustry.body).to_json

  # create active records
  Legislator.create!(name: legislator['name']['first'] + ' ' + legislator['name']['last'],
                     title: legislator['terms'][legislator['terms'].length - 1]['type'],
                     birthday: legislator['bio']['birthday'], gender: legislator['bio']['gender'],
                     cycle: candSummaryJSON['response']['summary']['@attributes']['cycle'],
                     state: getState(candSummaryJSON['response']['summary']['@attributes']['state']),
                     party: candSummaryJSON['response']['summary']['@attributes']['party'],
                     total_receipts: candSummaryJSON['response']['summary']['@attributes']['total'],
                     spent: candSummaryJSON['response']['summary']['@attributes']['spent'],
                     cash_on_hand: candSummaryJSON['response']['summary']['@attributes']['cash_on_hand'],
                     debt: candSummaryJSON['response']['summary']['@attributes']['debt'],
                     sourceOpenSecrets: candSummaryJSON['response']['summary']['@attributes']['source'],
                     candContributors: contribJSON,
                     candIndustries: industryJSON,
                     positions: positionsJSON,
                     contact_form: legislator['terms'][legislator['terms'].length - 1]['contact_form'],
                     address: legislator['terms'][legislator['terms'].length - 1]['address'],
                     phone: legislator['terms'][legislator['terms'].length - 1]['phone'])

end
