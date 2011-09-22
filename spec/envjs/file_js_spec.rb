require File.dirname(__FILE__) + '/../spec_helper'

describe 'file.js' do
  # specs don't change state, add variables, so using $browser for test spec
  
  it 'Envjs.getcwd returns the path for the main c8ke directory' do
    assert { js("Envjs.getcwd()") == File.expand_path(File.dirname(__FILE__) + "/../../")}
  end
  
  describe 'Envjs.writeToFile' do
    before do
      @path = File.expand_path(File.dirname(__FILE__) + "/../fixtures/file_write.txt")
      File.open(@path, 'w') do |f|
        f.write('')
      end
    end
    
    it 'overwrites what is already in the file' do
      text = "I can write!"
      js( "Envjs.writeToFile('#{text}', '#{@path}')" )
      assert { File.read(@path) == text }
    end
  end
  
  describe 'Envjs.readFromFile' do
    it 'only looks at local files' do
      assert { js("Envjs.readFromFile('http://google.com')") == nil }
    end
    
    it 'will read any file with a file:// address' do
      path = File.expand_path(File.dirname(__FILE__) + "/../fixtures/file_read.txt")
      contents = File.read(path);
    end
  end
end
