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

    def paginate(uri, response_key, storage, page=1)
      response = GitHub.get(uri + "?start_page=#{page}")
      parsed = JSON.parse(response.body)
      if parsed
        entries = parsed[response_key]
        unless entries.empty? || entries.nil?
          puts "writing #{entries.size}"
          entries.each { |entry| storage.write(entry.to_json + "\n") }
          storage.flush
          paginate(uri, response_key, storage, page + 1)
        end
      end
    end

    def crawl_repos(term)
      uri = GitHub::REPOS_URI + "/#{URI.encode(term)}"
      paginate(uri, 'repositories', open("repos.json", "w+"))
    end
  end
end


GitHub.crawl_repos("followers:[5 TO 100]")
