require File.dirname(__FILE__) + '/../spec_helper'

describe 'core.js' do
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
  
  # Envjs.Logging
  # Envjs.readConsole
end