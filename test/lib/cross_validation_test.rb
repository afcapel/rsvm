require_relative '../test_helper'

describe Svm::CrossValidation do
  HEART_SCALE_CSV = File.join(File.dirname(__FILE__), '..', 'fixtures', 'heart_scale.csv')
  UNBALANCED_CSV  = File.join(File.dirname(__FILE__), '..', 'fixtures', 'unbalanced.csv')

  it "can perfom cross validation" do
    problem = Svm::Problem.load_from_csv(HEART_SCALE_CSV)
  
    success_percentage = problem.accuracy_for_cross_validation(3, :c => 10, :gamma => 0.01)
    success_percentage.must_be :>, 0.8
  end
  
  it "can find the best parameters for the problem" do 
    problem = Svm::Problem.load_from_csv(HEART_SCALE_CSV)
  
    before = problem.accuracy_for_cross_validation(3, :c => 1, :gamma => 0.001)
  
    options = problem.find_best_parameters
  
    after = problem.accuracy_for_cross_validation(3, options)
  
    before.must_be :<, after
  end

  it "can cross validate unbalanced data" do
    problem = Svm::Problem.load_from_csv(UNBALANCED_CSV)
    
    options = problem.find_best_parameters(3)
    
    success_percentage = problem.accuracy_for_cross_validation(10, options)
    
    success_percentage.must_be :>, 0.8
  end
end
