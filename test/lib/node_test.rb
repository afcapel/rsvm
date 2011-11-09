require_relative '../test_helper'

describe Svm::Node do
  
  before do
    @node = Svm::Node.new
  end
    
  it "should have an index" do
    @node[:index].must_equal 0
    @node[:index] = 1
    @node[:index].must_equal 1
  end
  
  it "should have a value" do
    @node[:value].must_equal 0
    @node[:value] = 3.14
    @node[:value].must_equal 3.14
  end
end
