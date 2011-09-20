require File.dirname(__FILE__) + '/spec_helper'

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
    
    it 'makes $stdout available' do
      assert { js("Ruby.$stdout") == $stdout }
    end
    
    it 'makes $stderr available' do
      assert { js("Ruby.$stderr") == $stderr }
    end
  end
  
  describe 'file management' do
    describe 'Paths.available' do
      it 'loading files makes the directory available in the path' do
        @browser.load(@fixture_path + '/require_fixture.js')
        assert { js( "Paths.available").include?(@fixture_path) }
      end
    
      it 'loading a file twice does not add the path twice' do
        @browser.load(@fixture_path + '/require_fixture.js')
        @browser.load(@fixture_path + '/require_fixture.js')
        assert { js("Paths.available").select{|p| p == @fixture_path }.size == 1 }
      end
      
      it 'path can be added to manually' do
        @browser.add_path(@fixture_path)
        assert{ @browser.paths.include?( @fixture_path ) }
        assert{ js("Paths.available").include?( @fixture_path ) }
      end
    end
    
    describe 'File' do
      describe '.at(path)' do
        it 'will return false if a file is not found' do
          assert( js("File.at('/tmp/foo.footy')") == false )
        end
      
        it 'will look at an absolute location if passed an absolute path' do
          path = File.expand_path(@fixture_path + "/require_fixture.js")
          assert { js("File.at('#{path}')").path == path }
        end
      
        it 'will look in each of the Paths.available' do
          spec_dir = File.dirname(__FILE__)
          @browser.add_path(spec_dir)
          @browser.add_path(@fixture_path)
          assert { js("File.at('require_fixture.js')").path == spec_dir + '/fixtures/require_fixture.js' }
        end
      
        it 'will look for a .js file when not given a file type' do
          @browser.add_path(@fixture_path)
          assert { js("File.at('require_fixture')").path == @fixture_path + '/require_fixture.js' }
        end
      
        it 'makes #add_path available in the javascript as Paths.add' do
          deny { js("Paths.available").include?( @fixture_path ) }
          js("Paths.add('#{@fixture_path}')")
          assert { js("Paths.available").include?( @fixture_path ) }
        end
      end
    end
    
    describe 'require(file_path)' do
      it 'raises an error if it cannot find the file' do
        path = File.expand_path(@fixture_path + '/not_there')
        begin
          js("require('#{path}')")
        rescue Exception => e
          assert { e.message == "Cannot find required file: #{path}"}
        end
      end
      
      it 'makes the code available' do
        @browser.add_path(@fixture_path)
        js("require('require_fixture.js')")
        assert { js('RequireFixture.foo') == 'bar' }
      end
      
      it 'can go several layers deep in the require chain' do
        @browser.add_path(@fixture_path)
        js("require('deep.js')")
        assert { js('Deep.level') == 'one' }
        assert { js('Deeply.level') == 'two' }
        assert { js('Deeper.level') == 'three' }
      end
      
      it 'makes #add_path available in the javascript as Paths.add' do
        deny { js("Paths.available").include?( @fixture_path ) }
        js("Paths.add('#{@fixture_path}')")
        assert { js("Paths.available").include?( @fixture_path ) }
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
