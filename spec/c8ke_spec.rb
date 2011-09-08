require File.dirname(__FILE__) + '/spec_helper'

describe 'C8ke' do
  it 'the test should run' do
    expect_that { true.class == TrueClass }
  end
end
