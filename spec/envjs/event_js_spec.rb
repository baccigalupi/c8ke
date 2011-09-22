require File.dirname(__FILE__) + '/../spec_helper'

describe 'event.js' do
  # specs don't change state, add variables, so using $browser for test spec
  
  ['Event','MouseEvent','UIEvent','KeyboardEvent','MutationEvent','DocumentEvent','EventTarget','EventException'].each do |js_event|
    it "should make #{js_event} available" do
      assert { js("new #{js_event}('custom') instanceof #{js_event}") }
    end
  end
end


