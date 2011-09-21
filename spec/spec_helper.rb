require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'
require 'wrong/adapters/minitest'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'c8ke'

Wrong.config.alias_assert :expect
Wrong.config.color

def js(str)
  raise "@browser is not setup correctly" unless @browser.is_a?(C8ke::Browser)
  @browser.eval(str)
end

def setup_browser_and_mocking
  @browser = C8ke::Browser.new
  js(
    <<-JS
      var C8ke = {};
      C8ke.events = [];
      C8ke.add_event = function(e) { C8ke.events.push(e); };
      C8ke.clear_events = function(e) { C8ke.events = []; };
      C8ke.mock = function(message) { C8ke.add_event(message) };
      C8ke.mock_with_message = function(message) { return function(){ C8ke.add_event(message) } }
    JS
  )
end

def events
  js "C8ke.events"
end

def js_debug
  js "log.level=0;"
end


MiniTest::Unit.autorun
