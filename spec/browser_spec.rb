require File.dirname(__FILE__) + '/spec_helper'
require 'tempfile'

describe C8ke::Browser do
  before do
    @fixture_path = File.dirname(__FILE__) + '/fixtures'
    @browser = C8ke::Browser.new
  end
  
  describe 'basics' do
    it 'should go to string nicely' do
      assert { C8ke::Browser.new.to_s.size <= 100 }
    end
  end
  
  describe 'delegating ruby core methods' do
    it 'makes puts available' do
      output = capturing { js('Ruby.puts("foo")') }
      assert{ output == "foo\n" }
    end
    
    it 'creates a print method that takes a message' do
      output = capturing { js('print("bar")') }
      assert{ output == "bar\n" }
    end
    
    it 'makes #warn to acessible' do
      output = capturing(:stderr) { js('Ruby.warn("I am warning you sucker!")') }
      assert{ output == "I am warning you sucker!\n" }
    end
    
    it "makes the call stack available" do
      assert{ js("Ruby.caller()").join("\n").include?( File.dirname(__FILE__) ) }
    end
    
    it 'makes #rand available' do
      assert{ js("Ruby.rand(2)") <= 2.0 }
    end
    
    it 'makes #sleep available' do
      before_time = Time.now
      difference = 0.1
      js("Ruby.sleep(#{difference})")
      after_time = Time.now
      
      assert { after_time >= before_time + difference }
    end
    
    it 'allows calls to the unix command line' do
      pwd = js("Ruby.command_line('pwd')")
      assert { pwd == `pwd` }
    end
    
    it 'allows the raising of a ruby error from js' do
      begin
        js("Ruby.raise('This can be done!')")
      rescue Exception => e
        assert { e.class == V8::JSError }
        assert { e.message == "This can be done!" }
      end
    end
    
    it 'provides Ruby version information' do
      assert { js('Ruby.version') == RUBY_DESCRIPTION }
    end
  end
  
  describe 'file management' do
    describe 'Paths' do
      it 'loading files makes the directory available in the path' do
        @browser.load(@fixture_path + '/file_fixture.js')
        assert { js( "Paths").include?(@fixture_path) }
      end
    
      it 'loading a file twice does not add the path twice' do
        @browser.load(@fixture_path + '/file_fixture.js')
        @browser.load(@fixture_path + '/file_fixture.js')
        assert { js("Paths").select{|p| p == @fixture_path }.size == 1 }
      end
      
      it 'path can be added to manually' do
        @browser.add_path(@fixture_path)
        assert{ @browser.paths.include?( @fixture_path ) }
        assert{ js("Paths").include?( @fixture_path ) }
      end
    end
    
    describe 'File.at(path)' do
      it 'will return false if a file is not found' do
        assert( js("File.at('/tmp/foo.footy')") == false )
      end
      
      it 'will look at an absolute location if passed an absolute path' do
        temp = Tempfile.new 'foo'
        assert { js("File.at('#{temp.path}')").path == temp.path }
      end
      
      it 'will look in each of the Paths' do
        spec_dir = File.dirname(__FILE__)
        @browser.add_path(spec_dir)
        @browser.add_path(@fixture_path)
        assert { js("File.at('file_fixture.js')").path == spec_dir + '/fixtures/file_fixture.js' }
      end
      
      it 'makes #add_path available in the javascript as Paths.add' do
        deny { js("Paths").include?( @fixture_path ) }
        js("Paths.add('#{@fixture_path}')")
        assert { js("Paths").include?( @fixture_path ) }
      end
    end
    
    describe 'require(file_path)' do
      it 'raises an error if it cannot find the file' do
        begin
          js("require('/tmp/foofoo.bar')")
        rescue Exception => e
          assert { e.message == "Cannot find required file: /tmp/foofoo.bar"}
        end
      end
      
      it 'makes the code available' do
        @browser.add_path(@fixture_path)
        js("require('file_fixture.js')")
        assert { js('FileFixture.foo') == 'bar' }
      end
    end
  end
end
