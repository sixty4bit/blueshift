require 'fileutils'

namespace :blueshift do
  namespace :g do
    desc 'Generate a timestamped, empty Blueshift migration.'
    task :migration, :name do |_, args|
      if args[:name].nil?
        puts 'You must specify a migration name (e.g. rake generate:migration[create_events])!'
        exit false
      end

      content = "Blueshift.migration do\n  up do\n    \n  end\n\n  down do\n    \n  end\n\n  redup do\n    \n  end\n\n  reddown do\n    \n  end\nend\n"
      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      filename = File.join(Dir.pwd, 'db/migrations', "#{timestamp}_#{args[:name]}.rb")

      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, 'w') { |f| f << content }

      puts "Created the migration #{filename}"
    end
  end
end
