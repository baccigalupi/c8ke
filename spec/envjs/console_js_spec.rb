require File.dirname(__FILE__) + '/../spec_helper'

describe 'console.js' do
  before do
    setup_browser_and_mocking
  end
  
  it 'Envjs.log() delegates to print()' do
    js(
      <<-JS
        print = C8ke.mock;
        Envjs.log('foo you');
      JS
    )
    assert { events.include?('foo you') }
  end
  
  it 'Envjs.lineSource returns a somewhat useless string' do
    assert { js("Envjs.lineSource()") == "(line ?)"}
  end
  
  it 'Envjs.CURSOR gives the prompt cursor string' do
    assert { js("Envjs.CURSOR") == "envjs>" }
  end
  
  it 'makes the console object available' do
    output = capturing{ js("console.log('in the console.log');") }
    assert { output.include?('in the console.log') }
  end

  describe 'log' do
    it 'is automatically sent to warn level, and prints to the console' do
      output = capturing{ js " log.warn('Whoa!') " }
      assert { output.include?('Whoa!') }
    end
    
    it 'the log level can be adjusted' do
      output = capturing { 
        js <<-JS
          log.level = 0; // DEBUG
          log.debug('debugging ... please hold');
        JS
      }
      assert { output.include?( 'debugging ... please hold' ) }
    end
  end
  
  describe 'foo' do
    # var line = "";
    # Envjs.readConsole = function(){
    #   try{
    #     line = Ruby.$stdin.gets();
    #   }catch(e){
    #     console.log('ERROR : %s', e);
    #   }
    #   return line;
    # };
    # 
  end
end