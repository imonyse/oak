require 'helper'

class TestOak < Test::Unit::TestCase
  def setup
    create_temp_file
    @oak = Oak.new @test_tmp
  end

  def teardown
    clear_temp_file
  end

  def test_setup
    @oak.setup
    FileUtils.chdir @oak.destination_root do
      File.open('.gitignore') do |f|
        lines = f.readlines
        assert_equal('config/config.yml', lines[0].chomp)
      end
      
      branch = `git symbolic-ref -q HEAD`.chomp
      assert_equal('refs/heads/deploy', branch)
    end
  end
end
