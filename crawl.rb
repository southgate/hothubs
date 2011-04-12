require 'httparty'
require 'pp'
require 'json'

require 'uri'

# Fredom patch URI so it doesn't puke on [ or ] coming from HTTParty
module URI
  class << self

    def parse_with_safety(uri)
      URI::Parser.new(:UNRESERVED=>URI::PATTERN::UNRESERVED+'\[\]').parse uri
    end
    alias parse_without_safety parse
    alias parse parse_with_safety
  end
end

class GitHub
  include HTTParty

  base_uri "http://github.com/api/v2/json"

  REPOS_URI = base_uri + "/repos/search"

  class << self
    def parser
      URI::Parser.new(:UNRESERVED=>URI::PATTERN::UNRESERVED+'\[\]')
    end

    def repos(term, page = 1)
      uri = GitHub::REPOS_URI + "/#{URI.encode(term)}?start_page=#{page}"
      response = GitHub.get(uri)
      parsed = JSON.parse(response.body)
      parsed['repositories'] if parsed.has_key? 'repositories'
    end
  end
end


repos = GitHub.repos("followers:[5 TO 100]")
pp repos.map { |repo| repo['name'] }
