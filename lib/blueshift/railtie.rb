require 'rails'

module Blueshift
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/generate_migration.rake'
      load 'tasks/schema.rake'
    end
  end
end
