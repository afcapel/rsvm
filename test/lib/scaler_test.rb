require_relative '../test_helper'

describe Svm::Scaler do
  
  before do
    data = [
      [1, 12.0, -7.6, 100_000, 0],
      [0, 30.0, 0, -100_000, 0],
      [-1, 36.0, 7.6, 0, 0]
    ]
    
    @scaler = Svm::Scaler.scale(data)
  end
  
  it "finds the unit to scale" do
    @scaler.unit[0].must_equal(1)
    @scaler.unit[1].must_equal(12)
    @scaler.unit[2].must_equal(7.6)
    @scaler.unit[3].must_equal(100_000)
    @scaler.unit[4].must_equal(0)
  end
  
  it "finds the zero to scale" do
    @scaler.zero[0].must_equal(0)
    @scaler.zero[1].must_equal(24.0)
    @scaler.zero[2].must_equal(0)
    @scaler.zero[3].must_equal(0)
    @scaler.zero[4].must_equal(0)
  end
  
  it "scales the data" do
    @scaler.values_for_feature(0).must_equal [1, 0, -1]
    @scaler.values_for_feature(1).must_equal [-1, 0.5, 1]
    @scaler.values_for_feature(2).must_equal [-1, 0, 1]
    @scaler.values_for_feature(3).must_equal [1, -1, 0]
    @scaler.values_for_feature(4).must_equal [0, 0, 0]
  end
  
end