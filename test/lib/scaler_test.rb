require_relative '../test_helper'

describe Svm::Scaler do

  before do
    data = [
      [1, 12.0, -7.6, 100_000, 0],
      [2, 30.0, 0, -100_000, 0],
      [3, 36.0, 7.6, 0, 0]
    ]

    @scaler = Svm::Scaler.new(data)
    @scaler.scale!
  end

  it "doesn't scale the label data" do
    @scaler.labels.must_equal([1, 2, 3])
  end

  it "finds the unit to scale" do
    @scaler.unit[1].must_equal(12)
    @scaler.unit[2].must_equal(7.6)
    @scaler.unit[3].must_equal(100_000)
    @scaler.unit[4].must_equal(0)
  end

  it "finds the zero to scale" do
    @scaler.zero[1].must_equal(24.0)
    @scaler.zero[2].must_equal(0)
    @scaler.zero[3].must_equal(0)
    @scaler.zero[4].must_equal(0)
  end

  it "scales the data" do
    @scaler.values_for_feature(1).must_equal [-1, 0.5, 1]
    @scaler.values_for_feature(2).must_equal [-1, 0, 1]
    @scaler.values_for_feature(3).must_equal [1, -1, 0]
    @scaler.values_for_feature(4).must_equal [0, 0, 0]
  end
  
  it "can scale new input" do
    @scaler.scale([36.0, -7.6, 10_000, 1]).must_equal [1, -1, 0.1, 1]
  end

  it "can be saved to a file" do
    path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'scaler.yml')

    @scaler.save(path)

    recovered = Svm::Scaler.load(path)
    
    recovered.scale([36.0, -7.6, 10_000, 1]).must_equal [1, -1, 0.1, 1]

    File.delete(path)
  end

end