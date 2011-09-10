require File.dirname(__FILE__) + '/spec_helper'

describe C8ke::Browser do
  describe 'basics' do
    it 'should go to string nicely' do
      assert { C8ke::Browser.new.to_s.size <= 100 }
    end
  end
  
  describe 'configurations' do
    before do
      @fixture_path = File.dirname(__FILE__) + '/fixtures'
      @browser = C8ke::Browser.new
    end
    
    it 'loading files makes the directory available in the path' do
      @browser.load(@fixture_path + '/file_fixture.js')
      assert { @browser.eval( "path").include?(@fixture_path) }
    end
    
    it 'loading a file twice does not add the path twice' do
      @browser.load(@fixture_path + '/file_fixture.js')
      @browser.load(@fixture_path + '/file_fixture.js')
      assert { @browser.eval("path").select{|p| p == @fixture_path }.size == 1 }
    end
  end
end
