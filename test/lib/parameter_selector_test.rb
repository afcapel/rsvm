require_relative '../test_helper'
require 'csv'

describe Svm::ParameterSelector do
  
  before do
    csv_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'heart_scale.csv')
    data = CSV.read(csv_path)
    puts data.first.inspect
  end
  
  it "load data" do
  end
  
end