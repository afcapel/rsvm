module Svm
  class Scaler
    attr_reader :data
    attr_reader :num_samples
    attr_reader :num_features
    
    def self.scale(data)
      instance = self.new(data)
      instance.scale!
      
      instance.data
    end
    
    def initialize(data)
      @data = data
      
      @num_samples = data.size
      @num_features = data.first.size - 1
    end
    
    def scale!
      (1..num_features).each do |i|
        max = values_for_feature(i).max
        min = values_for_feature(i).min
        
        diff = (max - min).to_f
        
        unit[i] = diff/2.0
        zero[i] = min + unit[i]
      end
      
      data.each do |sample|
        (1..num_features).each do |i|
          new_value = sample[i] - zero[i]
          new_value = new_value / unit[i] unless unit[i] == 0
          sample[i] = new_value
        end
      end
    end
    
    def values_for_feature(i)
      @data.collect { |sample| sample[i] }
    end
    
    def labels
      values_for_feature 0
    end
    
    def unit
      @unit ||= []
    end
    
    def zero
      @zero ||= []
    end
  end
end