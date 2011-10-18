require 'thor'

class Oak < Thor
  include Thor::Actions

  def initialize(working_directory)
    super
    self.destination_root += '/' + working_directory
  end

  desc "setup oak", "Set current rails app source open ready"
  def setup
    FileUtils.chdir destination_root do
      check_cfg
      dummy_config 
      git_prepare
    end
  end

  no_tasks do

    def check_cfg
      ['config/application.rb', '.gitignore'].each do |f|
        if !File.exists? f
          raise "#{f} not found, are we at the root directory of a rails app?"
        end
      end

      # append config/config.yml to .gitignore if not already in 
      File.open('.gitignore') do |f|
        f.each_line do |l|
          if l == 'config/config.yml'
            return
          end
        end
      end

      append_to_file '.gitignore', 'config/config.yml'

    end

    def dummy_config
      File.open('config/config.example.yml', 'w') do |f|
        f.write "secret_token = 'c1cae0f52a3ef8efa369a127c63bd6ede539a4089fd952b33199100a6769c8455ab4969f2eefaf1ebcbe0208bd57531204c77f41f715207f961e7e45f139f4e7'"
      end
      prepend_to_file 'config/application.rb', "require 'yaml'\n APP_CONFIG = YAML.load(File.read(File.expand_path('../config.yml', __FILE__)))"

      File.open('config/database.example.yml', 'w') do |f|
        File.open('config/database.yml', 'r') do |o|
          f.write o.read
        end
      end
    end

    def git_prepare
      if File.exists? '.git'
        return
      end

      `git init && git add . && git commit -am "init"`
      `git checkout -b deploy`
    end
  end
end
