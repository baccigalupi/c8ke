require File.dirname(__FILE__) + '/../spec_helper'

describe 'xml_http_request.js' do
  before do
    setup_browser_and_mocking
  end
  
  describe 'XMLHttpRequest' do
    before do
      js "var request = new XMLHttpRequest()"
    end
    
    describe 'initial state' do
      it 'has an headers empty object' do
        assert { js("request.headers = {}") }
      end
      
      it 'has an empty response headers object'  do
        assert { js("request.responesHeaders = {}") }
      end
      
      it 'is has a state of not aborted' do
        assert { js("request.aborted == false") }
      end
    end
    
    describe '.open(method, url, async, user, password)' do
      it 'sets the readyState' do
        js "request.open('GET', 'http://google.com')"
        assert { js( "request.readyState" ) ==  1 }
      end
      
      describe 'async' do
        it 'default sets it to true' do
          js "request.open('GET', 'http://google.com')"
          assert { js('request.async') == true }
        end
        
        it 'will set it to false if that argument is passed in' do
          js "request.open('GET', 'http://google.com', false)"
          assert { js('request.async') == false }
        end
      end
      
      describe 'method' do
        it 'uses GET by default' do
          js "request.open(null, 'http://google.com')"
          assert { js('request.method') == "GET" }
        end
        
        it 'will use other passed in values' do
          js "request.open('DELETE', 'http://google.com')"
          assert { js('request.method') == "DELETE" }
        end
      end
      
      it 'normalizes the uri' do
        js <<-JS
          Envjs.uri = C8ke.mock;
          request.open(null, 'http://parseme.com');
        JS
        assert { events.include?( 'http://parseme.com' ) }
      end
      
      it 'calls .onreadystatechange' do
        js <<-JS
          request.onreadystatechange = C8ke.mock_with_message('called onreadystatechange');
          request.open(null, 'http://google.com');
        JS
        assert { events.include?( 'called onreadystatechange' ) }
      end
    end
    
    describe '.send(data, parsedoc, redirect_count)' do
      before do
        mock_responses
        js <<-JS
          // more mocking to get things working without everything
          Envjs.getCookies = C8ke.stub;
          var window = {};
          var Document = function(){}
          var setTimeout = function(fn, time){ fn.call() };
          
          request.open(null, 'http://google.com');
        JS
      end
      
      it 'make a HTTPConnection' do
        js "request.send()"
        assert { events.include?('getting http://google.com/') }
      end
    end
  end
end