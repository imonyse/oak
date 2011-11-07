require 'thor'

class Oak < Thor
  include Thor::Actions
  attr_reader :secret_token

  desc "setup oak", "Set current rails app source open ready"
  def setup(working_directory = '.')
    self.destination_root = working_directory
    FileUtils.chdir destination_root do
      check_cfg
      dummy_config 
      git_prepare
      create_config_on_deploy
      commit_deploy_branch
    end
  end

  no_tasks do

    def check_cfg
      ['config/application.rb', '.gitignore'].each do |f|
        if !File.exists? f
          raise "#{f} not found, are we at the root directory of a rails app?"
        end
      end

      # make 'config/database.yml' globally ignored
      global_ignore_file = File.expand_path('~/.gitignore')
      if File.exist? global_ignore_file
        ignored = File.binread global_ignore_file
        if !ignored.include?('config/database.yml')
          append_to_file(global_ignore_file, 'config/database.yml')
        end
      else
        File.open(global_ignore_file, 'w') do |f|
          f.write 'config/database.yml'
        end
      end
      `git config --global core.excludesfile ~/.gitignore`

      # append config/config.yml to .gitignore if not already in 
      File.open('.gitignore') do |f|
        f.each_line do |l|
          if l == 'config/config.yml'
            return
          end
        end
      end

      append_to_file '.gitignore', 'config/config.yml'

      # protect secret_token 
      full_text = File.binread 'config/initializers/secret_token.rb'
      full_text.gsub! /(Application\.config\.secret_token\s=\s)'(.*)'/, '\1APP_CONFIG[\'secret_token\']'
      # save per app secret_token for later use 
      @secret_token = "#{$2}"
      File.open('config/initializers/secret_token.rb', 'w') do |f|
        f.write full_text
      end
    end

    def dummy_config
      File.open('config/config.example.yml', 'w') do |f|
        f.write "secret_token: 'c1cae0f52a3ef8efa369a127c63bd6ede539a4089fd952b33199100a6769c8455ab4969f2eefaf1ebcbe0208bd57531204c77f41f715207f961e7e45f139f4e7'"
      end
      prepend_to_file 'config/application.rb', "require 'yaml'\nAPP_CONFIG = YAML.load(File.read(File.expand_path('../config.yml', __FILE__)))\n"

      # simply copy database.yml to database.example.yml
      File.open('config/database.example.yml', 'w') do |f|
        File.open('config/database.yml', 'r') do |o|
          f.write o.read
        end
      end
    end

    def git_prepare
      if File.exists? '.git'
        puts 'It seems a git repository has already created, I\'ll leave it untouched.'
        return
      end

      `git init && git add . && git commit -m "init"`
      `git checkout -b deploy`
    end

    def create_config_on_deploy
      File.open('config/config.yml', 'w') do |f|
        f.write 'secret_token: \'' + secret_token + '\''
      end

      # remove 'config/config.yml' from .gitignore on deploy branch
      ignored = File.binread('.gitignore')
      ignored.gsub! /config\/config.yml/, ''
      File.open('.gitignore', 'w') do |f|
        f.write ignored
      end

      # add checkout hook for switching from 'deploy' to 'master'
      File.open('.git/hooks/post-checkout', 'w') do |f|
        f.write <<-EOS
#!/bin/bash

branch_name=$(git symbolic-ref -q HEAD)
branch_name=${branch_name##refs/heads/}

if [ "$branch_name" = master -a -e "config/config.example.yml" ]; then
  cp config/config.example.yml config/config.yml
  echo "cp config/config.example.yml config/config.yml"
fi
        EOS
      end
      `chmod +x .git/hooks/post-checkout`
    end
    
    def commit_deploy_branch
      # commit deploy branch
      `git add . && git commit -m "deploy setup"`
      `git checkout master`
    end
  end
end
