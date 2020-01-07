require 'rubygems'
require 'mongoid'
require 'rake'
require 'database_cleaner'
require 'mongoid/version' # necessary for older versions of Mongoid (< ~3)

# Load rake tasks
load File.expand_path("../../lib/railties/denormalization.rake", __FILE__)
task :environment do
  Dir.chdir(File.dirname(__FILE__))
end

Mongoid.load!(File.expand_path('mongoid.yml', File.dirname(__FILE__)), :test)

Mongoid::Config.belongs_to_required_by_default = false

require File.expand_path("../../lib/mongoid/denormalization", __FILE__)
require File.expand_path("../../spec/app/models/user", __FILE__)
require File.expand_path("../../spec/app/models/post", __FILE__)
require File.expand_path("../../spec/app/models/article", __FILE__)
require File.expand_path("../../spec/app/models/comment", __FILE__)

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
