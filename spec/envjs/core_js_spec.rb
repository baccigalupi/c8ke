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
    it 'evaluates in the __this__ context' do
      js <<-JS
        var thingy;
        var fn = function(){
          Envjs.eval(__this__, "thingy = 'foo'");
        };
        fn();
      JS
      assert { js('thingy') == 'foo' }
    end
    
    # it "should eval in another context ???, not sure how to test"
  end
  
  describe 'js threadless-ness' do
    it 'Envjs.sync does not work and it will just call the function directly' do
      output = capturing{ js 'Envjs.sync(function(){ C8ke.add_event("in the sync") });' }
      assert { output.include?("c8ke js is threadless") }
      assert { events.include?('in the sync')}
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
  
  # Envjs.connection
  # Envjs.urlparse.urlsplit
  # Envjs.localXHR
  
  # Envjs.__defineGetter__
  # Envjs.__defineSetter__
  
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
