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
      
      // good for mocking a function where you just want to check the first arg
      C8ke.mock = function(message, return_value) { 
        C8ke.add_event(message); 
        return return_value;
      }; 
      
      // goodd for asserting a custom message
      C8ke.mock_with_message = function(message, return_value) { 
        return function(){ 
          C8ke.add_event(message);
          return return_value;
        } 
      }
      
      // stub or the null function
      C8ke.stub = function(return_value){ return return_value };
    JS
  )
end

def events
  js "C8ke.events"
end

def mock_responses
  js <<-JS
    var response = {raw_headers: {raw_foo: 'raw foo yo!'}};
    response.code = function(){return 200;};
    response.description = function(){ return 'all is well';};
    response.body = function(){ return 'body' };
  
    // mocking the HTTP requests
    Envjs.localXHR = C8ke.mock;
    Envjs.HTTPConnection.get = function(url) { 
      C8ke.add_event('getting ' + url); 
      return response; 
    }; 
    Envjs.HTTPConnection.post = function(url, data) { 
      C8ke.add_event('posting ' + url + ' with data: ' + data ); 
      return response;
    };
  JS
end

def js_debug
  js "log.level=0;"
end


MiniTest::Unit.autorun
