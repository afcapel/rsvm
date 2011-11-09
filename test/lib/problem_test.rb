require_relative '../test_helper'

describe Svm::Problem do
  
  before do
    @problem = Svm::Problem.new([
      [[1, 0, 1], 1],
      [[-1, 0, -1], -1]
    ])
  end
    
  it "stores problem values" do
    @problem.value(0).must_equal(1.0)
    @problem.value(1).must_equal(-1)
  end
  
  it "stores samples features" do
    @problem.sample(0).must_equal([1, 0, 1])
    @problem.sample(1).must_equal([-1, 0, -1])
  end
end
