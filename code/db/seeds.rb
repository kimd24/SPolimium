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


fakeurl = "https://raw.githubusercontent.com/maltyeva/iba-cocktails/master/recipes.json"
Cocktail.delete_all if Rails.env.development?

LegislatorsURL = "https://theunitedstates.io/congress-legislators/legislators-current.json"
Legislator.delete_all if Rails.env.development?

cocktails = JSON.parse(open(fakeurl).read)
cocktails.each do |cocktail|
  Cocktail.create!(name: cocktail["name"], glass: cocktail["glass"], ingredients: cocktail["ingredients"], preparation: cocktail["preparation"])
end
legislators = JSON.parse(open(LegislatorsURL).read)
legislators.each do |legislator|
  #unless legislator["id"]["opensecrets"] == nil
    candSummaryURL = "http://www.opensecrets.org/api/?method=candSummary&cid=" + legislator["id"]["opensecrets"] + "&apikey=" + ENV['openSecretsKey'] + "&output=json"
    candContrib = "http://www.opensecrets.org/api/?method=candContrib&cid=" + legislator["id"]["opensecrets"] + "&apikey=" + ENV['openSecretsKey'] + "&output=json"
    candIndustry = "http://www.opensecrets.org/api/?method=candIndustry&cid=" + legislator["id"]["opensecrets"] + "&apikey=" + ENV['openSecretsKey'] + "&output=json"
    candSummary = JSON.parse(open(candSummaryURL).read)
  #end
  #Legislator.create!(name: legislator["name"]["first"] + " " + legislator["name"]["last"], birthday: legislator["bio"]["birthday"], gender: legislator["bio"]["gender"], cycle: candSummary["response"]["summary"]["@attributes"]["cycle"], state: candSummary["response"]["summary"]["@attributes"]["state"], party: candSummary["response"]["summary"]["@attributes"]["party"], total_receipts: candSummary["response"]["summary"]["@attributes"]["total"], spent: candSummary["response"]["summary"]["@attributes"]["spent"], cash_on_hand: candSummary["response"]["summary"]["@attributes"]["cash_on_hand"], debt: candSummary["response"]["summary"]["@attributes"]["debt"], sourceOpenSecrets: candSummary["response"]["summary"]["@attributes"]["source"], candContributors: candContrib, candIndustries: candIndustry)

end
