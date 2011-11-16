module Svm
  class ParameterError < StandardError; end
  
  class Options
    attr_reader :parameter_struct
    
    DEFAULT_OPTIONS = {
      :svm_type         => :c_svc,
      :kernel_type      => :rbf,
      :degree           => 3,
      :gamma            => 0,
      :coef0            => 0,
      :nu               => 0.5,
      :cache_size       => 100.0,
      :c                => 1,
      :eps              => 0.001,
      :p                => 0.1,
      :shrinking        => 1,
      :probability      => 0,
      :nr_weight        => 0,
      :cross_validation => 0,
      :nr_fold          => 0,
      :scale            => true
    }
    
    def initialize(user_options = {})
      @parameter_struct = ParameterStruct.new
      add(DEFAULT_OPTIONS.merge(user_options))
    end
    
    def add(more_options)
      options_hash.merge!(more_options)
      
      more_options.each do |key, value|
        parameter_struct[key] = value if parameter_struct.members.include?(key)
      end
    end
    
    def label_weights=(weights)
      num_labels = weights.keys.size
      
      parameter_struct[:nr_weight] = num_labels
      
      parameter_struct[:weight_label] = FFI::MemoryPointer.new(:int, num_labels)
      parameter_struct[:weight]       = FFI::MemoryPointer.new(:double, num_labels)
      
      labels_array = weights.keys.collect(&:to_i)
      
      parameter_struct[:weight_label].write_array_of_int(labels_array)
      parameter_struct[:weight].write_array_of_double(weights.values) 
    end
    
    
    def [](option)
      options_hash[option]
    end
    
    private
    
    def options_hash
      @options_hash ||= {}
    end
  end
end