require File.dirname(__FILE__) + '/../spec_helper'

describe 'connection.js' do
  before do
    setup_browser_and_mocking
  end
  
  describe 'Envjs.localXHR' do
    before do
      js <<-JS 
        var mock_xhr = {responseHeaders:{}};
      JS
    end
    
    describe 'get' do
      before do
        @path = File.expand_path(File.dirname(__FILE__) + "/../fixtures/get_local_xhr.html")
        js <<-JS
          mock_xhr.method = 'GET';
          Envjs.localXHR("file://#{@path}", mock_xhr, {});
        JS
      end
      
      it 'should get the contents of a file' do
        response_text = js("mock_xhr.responseText")
        assert { response_text == File.read(@path) }
      end
      
      it 'should set the response header to the file type' do
        content_type = js('mock_xhr.responseHeaders["Content-Type"]')
        assert { content_type == 'text/html'}
      end
    end
    
    describe 'post' do
      before do
        @path = File.expand_path(File.dirname(__FILE__) + "/../fixtures/post_local_xhr.html")
        File.delete(path) if File.exist?(path)
        
        js <<-JS
          mock_xhr.method = 'POST';
          Envjs.localXHR("file://#{@path}", mock_xhr, "<p>Yo baby, yo baby, yo!</p>");
        JS
        
        assert { File.read(@path).include?('Yo baby, yo baby, yo!')}
      end
    end
  end

  describe 'Envjs.connections' do
    before do
      js <<-JS
        var foo = {foo: 'foo'};
        var bar = {bar: 'bar'};
        Envjs.connections.addConnection(foo);
        Envjs.connections.addConnection(bar);
      JS
    end
    
    it 'can add a connections' do
      assert{ js("Envjs.connections").include?(js('foo'))}
      assert{ js("Envjs.connections").include?(js('bar'))}
    end
    
    it 'can remove connections' do
      js "Envjs.connections.removeConnection(bar)"
      deny{ js("Envjs.connections").include?(js("bar")) }
    end
  end

  describe 'Envjs.HTTPConnection' do
    it 'calls through native Ruby via RestClient' do
      skip # good reality check, but bad for test dependency!
      google_js = js( "Envjs.HTTPConnection.get('http://google.com')" )
      assert { google_js.match /google/i }
    end
  end

  describe 'Envjs.connection' do
    before do
      js <<-JS
        // mocking Document data
        var Document = function(){};
        var doc = new Document();
        var XMLSerializer = function(){};
        XMLSerializer.prototype.serializeToString=  function(data) { C8ke.add_event('serializing data') };
        
        // mocking the response
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
        
        // mocking the xhr object
        var xhr = {method: 'GET', responseHeaders:{}};
      JS
    end
    
    it 'uses the local xhr system when url starts with file://' do
      @path = File.expand_path(File.dirname(__FILE__) + "/../fixtures/get_local_xhr.html")
      js <<-JS
        xhr.url = "file://#{@path}";
        Envjs.connection(xhr);
      JS
      assert { events.include?("file://#{@path}") }
    end
    
    it 'serializes data to xml when data is a Document' do
      js <<-JS
        xhr.method = 'POST'
        xhr.url = "http://google.com";
        Envjs.connection(xhr, null, doc);
      JS
      assert { events.include?('serializing data') }
    end
    
    it 'makes requests via Envjs.HTTPConnection' do
      js <<-JS
        xhr.url = "http://google.com";
        Envjs.connection(xhr);
      JS
      assert { events.include?("getting http://google.com") }
      
      js <<-JS
        xhr.method = 'POST';
        xhr.url = "http://google.com";
        Envjs.connection(xhr, null, {one: 1});
      JS
      assert { events.join().include?("posting http://google.com with data:") }
    end
    
    it 'sets the response headers' do
      js <<-JS
        xhr.url = "http://google.com";
        Envjs.connection(xhr);
      JS
      assert { js("xhr.responseHeaders.raw_foo") == 'raw foo yo!'}
    end
    
    it 'sets xhr status stuff' do
      js <<-JS
        xhr.url = "http://google.com";
        Envjs.connection(xhr);
      JS
      assert { js("xhr.status") == 200 }
      assert { js("xhr.statusText") == "all is well" }
      assert { js("xhr.responseText") == "body" }
    end
    
    it 'calls the response handler function if one is provided' do
      js <<-JS
        xhr.url = "http://google.com";
        Envjs.connection( xhr, function(){ C8ke.add_event('in the callback')} );
      JS
      assert { events.include?('in the callback') }
    end
  end
end