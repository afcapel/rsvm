require 'yaml'

module Svm
  class Scaler
    attr_reader :data
    attr_reader :num_samples
    attr_reader :num_features
    
    def self.scale(data)
      instance = self.new(data)
      instance.scale!
      
      instance
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
      
      data.collect { |sample| scale(sample, true) }
    end
    
    def scale(sample, with_labels = false)
      # If the sample does't have label it should be accessed
      # one more position to the left
      offset = with_labels ? 0 : -1
      
      (1..num_features).each do |i|
        new_value = sample[i+offset] - zero[i]
        new_value = new_value / unit[i] unless unit[i] == 0
        sample[i+offset] = new_value
      end
      
      sample
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
    
    # Release references to data so it can be garbage collected
    def release_data!
      @data = nil
    end
    
    def to_yaml_properties
      %w{ @num_features @unit @zero }
    end
    
    def save(path)
      File.open(path, 'w+') do |f|
        f.write(YAML.dump(self))
      end
    end
    
    def self.load(path)
      YAML.load(File.read(path))
    end
  end
end