require File.dirname(__FILE__) + '/../spec_helper'

describe 'core.js' do
  include Config
  
  before do
    setup_browser_and_mocking
  end
  
  it 'defines Envjs basic identifiers' do
    assert{ js("Envjs.platform") ==     "V8 RubyRacer" }
    assert{ js("Envjs.revision") ==     ENV['RUBY_VERSION'] }
    assert{ js("Envjs.javaEnabled") ==  false }
    assert{ js("Envjs.homedir") ==      ENV['HOME'] }
    assert{ js("Envjs.os_name") ==      CONFIG['host_os']}
    assert{ js("Envjs.os_arch") ==      CONFIG['host_cpu']}
    assert{ js("Envjs.lang") ==         ENV['LANG'] }
    
    # assert{ js("Envjs.tmpdir") ==       C8ke::Browser::ENV['TMPDIR'] }
  end
  
  it 'does not crash the thread when it exits' do
    js('Envjs.exit()')
  end
  
  describe 'Envjs.eval' do
    it 'evaluates in the World context' do
      js <<-JS
        var thingy;
        var fn = function(){
          Envjs.eval(World, "thingy = 'foo'");
        };
        fn();
      JS
      assert { js('thingy') == 'foo' }
    end
    
    # it "should eval in another context ???"
  end
  
  describe 'js threadless-ness' do
    it 'Envjs.sync does not work' do
      output = capturing{ js 'Envjs.sync()' }
      assert { output.include?("c8ke js is threadless. Syncing is not possible!") }
    end
    
    it 'Envjs.spawn just calls the function' do
      js <<-JS
        var foo = function(){print('foo');};
      JS
      output = capturing { js "Envjs.spawn(foo)" }
      assert { output.include? 'foo' }
    end
  end
  
  describe 'Envjs.sleep' do
    it 'will call Ruby.sleep in milliseconds' do
      js <<-JS
        Ruby.sleep = function(amount) { C8ke.add_event("sleeping for " + amount + " seconds") }
        Envjs.sleep(1500);
      JS
      assert { events.include?( "sleeping for 1.5 seconds" ) }
    end
  end
  
  describe 'Envjs.guid' do
    it 'return a global incrementing integer' do
      assert { js("Envjs.guid()") == 1 }
      assert { js("Envjs.guid()") == 2 }
      assert { js("Envjs.guid()") == 3 }
      @browser = C8ke::Browser.new
      assert { js("Envjs.guid()") == 1 }
    end
  end
  
  # Envjs.proxy
  
  # Envjs.logger
  # Envjs.getcwd
  # Envjs.readFromFile
  # Envjs.writeToFile
  # Envjs.writeToTempFile
  # Envjs.readFromFile 
  # Envjs.deleteFile
  
  # Envjs.connection
  # Envjs.urlsplit
  # Envjs.localXHR
  
  # Envjs.__defineGetter__
  # Envjs.__defineSetter__
  # Envjs.appCodeName  = "Envjs";
  # Envjs.appName      = "Netscape";
  # Envjs.version = "1.618";//
  # Envjs.revision = '';
  # Envjs.gc = function(){ Ruby.gc(); };
  
  # Envjs.Configuration
  # Envjs.config
  # Envjs.guid
  
  # Envjs.eventLoop
  # Envjs.on
  # Envjs.once
  # Envjs.removeListener
  # Envjs.removeAllListeners
  # Envjs.listeners
  # Envjs.emit
  # Envjs.tick
  # Envjs.argv
  # Envjs.runAsync
  # Envjs.connections
  # Envjs.timers
  # Envjs.MIN_TIMER_TIME
  # Envjs.normalizeTime
  # Envjs.guid
  # Envjs.wait
  # Envjs.defaultEventBehaviors
  # Envjs.serializeForm
  # Envjs.uri
  # 
  # Envjs.scriptTypes
  # Envjs.onScriptLoadError
  # Envjs.loadInlineScript
  # Envjs.loadLocalScript
  # Envjs.beforeScriptLoad
  # Envjs.afterScriptLoad
  # Envjs.loadImage
  # Envjs.loadLink
  # Envjs.exchangeHTMLDocument
  # Envjs.cookieFile
  # Envjs.saveCookies
  # Envjs.loadCookies
  # Envjs.homedir
  # Envjs.cookies
  # Envjs.setCookie
  # Envjs.getCookies
  # 
  # Envjs.userAgents
  # Envjs.windows
  # Envjs.loadFrame
  # Envjs.unloadFrame
  
end
