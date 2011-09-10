require File.dirname(__FILE__) + '/spec_helper'

describe C8ke do
  describe 'basics' do
    it 'should make v8 available' do
      assert { defined?(V8) == 'constant' }
    end
  end
end
