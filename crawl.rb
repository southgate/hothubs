require 'httparty'
require 'pp'
require 'json'

class GitHub
  include HTTParty

  base_uri "http://github.com/api/v2/json"

  REPOS_URI = base_uri + "/repos/search"

  def self.repos(term, page = 1)
    uri = GitHub::REPOS_URI + "/#{term}?start_page=#{page}"
    response = GitHub.get(uri)
    parsed = JSON.parse(response.body)
    parsed['repositories'] if parsed.has_key? 'repositories'
  end
end


repos = GitHub.repos("*")
pp repos.map { |repo| repo['name'] }
