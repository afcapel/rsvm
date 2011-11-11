require_relative '../test_helper'

describe Svm::Problem do
  
  before do
    @problem = Svm::Problem.new([
      [1, 1, 0, 1],
      [-1, -1, 0, -1]
    ])
  end
  
  it "stores the samples length" do
    @problem.length.must_equal(2)
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
  
  it "can perfom cross validation" do
    GC.start # TODO: Investigate why this is needed. It randomly crashes without it.
    
    csv_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'heart_scale.csv')
    
    problem = Svm::Problem.load_from_csv(csv_path)
    success_percentage = problem.cross_validate(10, :kernel_type => :linear, :c => 10)
    success_percentage.must_be :>, 0.8
  end
end
