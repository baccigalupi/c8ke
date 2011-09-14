require File.dirname(__FILE__) + '/../spec_helper'

describe 'core.js' do
  include Config
  
  before do
    @browser = C8ke::Browser.new
    js(
      <<-JS
        var C8ke = {};
        C8ke.events = [];
        C8ke.add_event = function(e){ C8ke.events.push(e); };
        C8ke.clear_events = function(e){ C8ke.events = []; };
        C8ke.mock = function(message) { C8ke.add_event(message) };
      JS
    )
  end
  
  def events
    js "C8ke.events"
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
  
  describe 'console' do
    it 'Envjs.log' do
      js(
        <<-JS
          print = C8ke.mock;
          Envjs.log('foo you');
        JS
      )
      assert { events.include?('foo you') }
    end
  end
  
  # Envjs.log 
  # Envjs.Logging
  # Envjs.trace
  # Envjs.lineSource
  # Envjs.readConsole
  # Envjs.prompt
  # Envjs.CURSOR
  # Envjs.repl
  
  # Envjs.eval
  # Envjs.sync
  # Envjs.spawn
  # Envjs.sleep
  
  
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
