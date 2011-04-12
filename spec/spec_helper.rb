$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

SUPPORT = File.join(File.dirname(__FILE__), "support")
$LOAD_PATH.unshift(SUPPORT)

require "mongoid"
require "rspec"

LOGGER = Logger.new($stdout)

Mongoid.configure do |config|
  name = "hothubs_test"
  config.master = Mongo::Connection.new.db(name)
  config.logger = nil
end

Dir[ File.join(SUPPORT, "*.rb") ].each { |file| require File.basename(file) }

Rspec.configure do |config|
  config.mock_with(:rspec)
  config.after(:suite) do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
