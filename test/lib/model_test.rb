require_relative '../test_helper'

describe Svm::Model do
  
  before do
    @problem = Svm::Problem.new([
      [[1, 0, 1], 1],
      [[-1, 0, -1], -1]
    ])
  end
  
  it "store the passed parameters" do
    model = @problem.generate_model(:kernel_type => :linear, :c => 15)
    
    param_struct = model.model_struct[:param]
    
    param_struct[:kernel_type].must_equal(:linear)
    param_struct[:c].must_equal(15)
  end
  
  it "can make a prediction for a sample" do
    model = @problem.generate_model(:kernel_type => :linear, :c => 10)
    
    model.predict([-1, 0, -1]).must_equal(-1)
    model.predict([1,  0,  1]).must_equal(1)
  end
end
