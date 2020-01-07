require 'rails'

module Mongoid::Denormalization
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'railties/denormalize.rake'
    end
  end
end