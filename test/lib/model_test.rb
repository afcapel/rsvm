require_relative '../test_helper'

describe Svm::Model do
  
  before do
    @problem = Svm::Problem.new([
      [[1, 0, 1], 1],
      [[-1, 0, -1], -1]
    ])
    
    @model = @problem.generate_model
  end
  
  it "can make a prediction for a sample" do
    @model.predict([-1, 0, -1]).must_equal(-1)
  end
end
