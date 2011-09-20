require File.dirname(__FILE__) + '/../spec_helper'

describe 'connection.js' do
  describe 'Envjs.localXHR' do
    before do
      setup_browser_and_mocking
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
end