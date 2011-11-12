require_relative '../test_helper'

describe Svm::CrossValidation do
  
  before do
    csv_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'heart_scale.csv')
    
    @problem = Svm::Problem.load_from_csv(csv_path)
  end
  
  it "can perfom cross validation" do
    success_percentage = @problem.accuracy_for_cross_validation(3, :c => 10, :gamma => 0.01)
    success_percentage.must_be :>, 0.8
  end
  
  it "can find the best parameters for the problem" do   
    before = @problem.accuracy_for_cross_validation(3, :c => 1, :gamma => 0.001)
     
    options = @problem.find_best_parameters
    
    after = @problem.accuracy_for_cross_validation(3, options)
    
    before.must_be :<, after
  end
end
