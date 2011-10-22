require 'helper'

class TestOak < Test::Unit::TestCase
  def setup
    @oak = Oak.new
    create_temp_file @oak
  end

  def teardown
    clear_temp_file @oak
  end

  def test_check_cfg
    FileUtils.cd @oak.destination_root do
      @oak.check_cfg
      assert_equal('config/config.yml', File.binread('.gitignore'))
      assert_equal('c1cae0f52a3ef8efa369a127c63bd6ede539a4089fd952b33199100a6769c8455ab4969f2eefaf1ebcbe0208bd57531204c77f41f715207f961e7e45f139f4e7', @oak.secret_token)
      ignored = File.binread(File.expand_path('~/.gitignore'))
      assert(ignored.include?('config/database.yml'))
    end
  end

  def test_create_config_on_deploy
    FileUtils.cd @oak.destination_root do
      @oak.check_cfg
      @oak.git_prepare
      @oak.create_config_on_deploy
      assert_equal('secret_token = ' + @oak.secret_token, File.binread('config/config.yml'))
    end
  end

  def test_setup
    @oak.setup @oak.destination_root
    FileUtils.chdir @oak.destination_root do
      File.open('.gitignore') do |f|
        lines = f.readlines
        assert_equal('config/config.yml', lines[0].chomp)
      end
      
      branch = `git symbolic-ref -q HEAD`.chomp
      assert_equal('refs/heads/master', branch)
    end
  end
end
