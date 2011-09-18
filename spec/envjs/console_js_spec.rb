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
    it 'setting the level should obscure output at a higher level'
    it 'should pretty print the object'
  end
  
  # ??
  # Envjs.Logging
  # Envjs.readConsole
end