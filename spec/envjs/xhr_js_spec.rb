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
  
  describe 'Location' do
    before do
      mock_responses
      @href = 'http://www.google.com:80/search?q=c8ke#test'
      js <<-JS
        var loc = new Location("#{@href}");
      JS
    end
    
    describe 'initialization with a url' do
      it 'sets the hash' do
        assert { js("loc.hash") == "#test"}
      end
    
      it 'sets the host' do
        assert { js("loc.host") == "www.google.com:80"}
      end
    
      it 'sets the host' do
        assert { js("loc.hostname") == "www.google.com"}
      end
    
      it 'sets the href' do
        assert { js("loc.href") == @href}
      end
    
      it 'sets the pathname' do
        assert { js("loc.pathname") == '/search'}
      end
    
      it 'sets the protocol' do
        assert { js("loc.protocol") == 'http:'}
      end
    
      it 'sets the port' do
        assert { js("loc.port") == '80'}
      end
    
      it 'sets the search' do
        assert { js("loc.search") == '?q=c8ke'}
      end
    end
    
    describe 'setting attributes' do
      describe 'protocol' do
        it 'to an exact value' do
          js("loc.protocol = 'https:'")
          assert{ js('loc.protocol') == 'https:'}
        end
      
        it 'will append the colon if ommitted' do
          js("loc.protocol = 'https'")
          assert{ js('loc.protocol') == 'https:'}
        end
      end
      
      describe 'host' do
        it 'works' do
          js("loc.host = 'www.yahoo.com'");
          assert { js('loc.host') == 'www.yahoo.com' }
        end
        
        it 'updates the hostname, port and href too' do
          js("loc.host = 'www.yahoo.com'")
          assert { js('loc.hostname') == 'www.yahoo.com'}
          assert { js('loc.host') == 'www.yahoo.com'}
          assert { js('loc.href') == 'http://www.yahoo.com/search?q=c8ke#test'}
        end
      end
    
      describe 'port' do
        it 'works' do
          js("loc.port = 81")
          assert{ js('loc.port') == '81' }
        end
        
        it 'also updates the host and href' do
          js("loc.port = '81'")
          assert{ js('loc.port') == '81'}
          assert{ js('loc.host') == 'www.google.com:81' }
          assert{ js('loc.href') == 'http://www.google.com:81/search?q=c8ke#test' }
        end
      end
      
      describe 'pathname' do
        it 'works' do
          js("loc.pathname = '/foo'")
          assert{ js('loc.pathname') == '/foo' }
        end
        
        it 'appends the beginning slash when omitted' do
          js("loc.pathname = 'foobar'")
          assert{ js('loc.pathname') == '/foobar' }
        end
        
        it 'also updates the href' do
          js("loc.pathname = '/foobar'")
          assert{ js('loc.href') == 'http://www.google.com:80/foobar?q=c8ke#test'}
        end
      end

      describe 'search' do
        it 'works' do
          js("loc.search = '?q=foo'")
          assert{ js('loc.search') == '?q=foo' }
        end
        
        it 'appends the beggining ? when omitted' do
          js("loc.search = 'q=foo'")
          assert{ js('loc.search')  == '?q=foo' }
        end
        
        it 'also sets the href' do
          js("loc.search = '?q=foo'")
          assert{ js('loc.href') == 'http://www.google.com:80/search?q=foo#test' }
        end
      end
      
      describe 'hash' do
        it 'works' do
          js("loc.hash = '#foo'")
          assert{ js('loc.hash') == '#foo' }
        end
        
        it 'appends the beginning hash mark when needed' do
          js("loc.hash = 'foo'")
          assert{ js('loc.hash') == '#foo' }
        end
        
        it 'changes the href' do
          js("loc.hash = '#foo'")
          assert{ js('loc.href') == 'http://www.google.com:80/search?q=c8ke#foo' }
        end
      end
    end
  end
end