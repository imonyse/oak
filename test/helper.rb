require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'oak'

class Test::Unit::TestCase
  def create_temp_file
    @test_tmp = 'test_tmp'
    FileUtils.cp_r 'test/files', 'test_tmp'
    FileUtils.mv 'test_tmp/dot_gitignore', 'test_tmp/.gitignore'
  end

  def clear_temp_file
    FileUtils.rm_rf @test_tmp
  end
end
