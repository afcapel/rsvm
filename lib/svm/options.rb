module Svm
  class Options
    attr_reader :parameter_struct
    attr_reader :options
    
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
      :nr_fold          => 0
    }
    
    def initialize(user_options = {})
      @parameter_struct = ParameterStruct.new
      
      @options = DEFAULT_OPTIONS.merge(user_options)
      
      options.each do |key, value|
        parameter_struct[key] = value if parameter_struct.members.include?(key)
      end
    end
    
    def label_weights=(weights)
      parameter_struct[:nr_weight] = weights.keys.size
      
      @labels  = FFI::MemoryPointer.new(:int, weights.size)
      @weights = FFI::MemoryPointer.new(:double, weights.size)
      
      labels_array = weights.keys.collect(&:to_i)
      
      @labels.write_array_of_int(labels_array)
      @weights.write_array_of_double(weights.values)
    end
  end
end