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
      @problem.generate_model(:kernel_type => :linear, :c => -10)
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

  it "stores the number of classes" do
    model = @problem.generate_model(:kernel_type => :linear, :c => 20)
    model.number_of_classes.must_equal 2
  end

  it "stores the labels" do
    model = @problem.generate_model(:kernel_type => :linear, :c => 10)
    model.labels.sort.must_equal [-1, 1]
  end

  it "can predict probabilities" do
    csv_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'heart_scale.csv')
    problem = Svm::Problem.load_from_csv(csv_path)

    problem.estimate_probabilities = true

    model = problem.generate_model

    sample = [60.0, 1.0, 3.0, 140.0, 185.0, 0.0, 2.0, 155.0, 0.0, 3.0, 2.0, 0.0, 3.0]
    probs = model.predict_probabilities(sample)

    probs.values.each do |p|
      p.must_be :>=, 0
      p.must_be :<=, 1
    end

    probs.values.inject(&:+).must_be_close_to 1, 0.01
  end

end
