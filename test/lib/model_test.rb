require_relative '../test_helper'
require 'tempfile'

describe Svm::Model do
  
  before do
    @problem = Svm::Problem.new
    @problem.data = [
      [1, 1, 0, 1],
      [-1, -1, 0, -1]
    ]
  end
  
  it "stores the passed parameters" do
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
  
  it "must raise an exception if training parameters are not valid" do
    
    proc {
      model = @problem.generate_model(:kernel_type => :linear, :c => -10)
    }.must_raise Svm::ParameterError
    
  end
  
  it "can be saved to a file" do
    file = Tempfile.new('model')
    
    begin
       model = @problem.generate_model(:kernel_type => :linear, :c => 20)
       model.save(file.path)
  
       loaded_model = Svm::Model.load(file.path)
  
       loaded_model.predict([-1, 0, -1]).must_equal(-1)
       loaded_model.predict([1,  0,  1]).must_equal(1)
    ensure
       file.close
       file.unlink   # deletes the temp file
    end
  end
  
end
