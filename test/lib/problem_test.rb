require_relative '../test_helper'

describe Svm::Problem do
  
  before do
    @problem = Svm::Problem.new
    @problem.data = [
      [1, 1, 0, 1],
      [-1, -1, 0, -1],
      [-1, -1, -1, -1]
    ]
  end
  
  it "stores the samples length" do
    @problem.length.must_equal(3)
  end
    
  it "stores problem values" do
    @problem.value(0).must_equal(1.0)
    @problem.value(1).must_equal(-1)
  end
  
  it "stores samples features" do
    @problem.sample(0).must_equal([1, 0, 1])
    @problem.sample(1).must_equal([-1, 0, -1])
  end
  
  it "can generate a model" do
    model = @problem.generate_model
    model.must_be_instance_of Svm::Model
  end
  
  it "can suggets weights for labels" do
    @problem.labels.sort.must_equal [-1, 1]
    
    @problem.suggested_labels_weights[1].must_equal(1.0/3)
    @problem.suggested_labels_weights[-1].must_equal(2.0/3)
  end
end
