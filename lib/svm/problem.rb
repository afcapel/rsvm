require 'csv'

module Svm
  class ParameterError < StandardError; end
    
  class Problem
    include CrossValidation
    
    attr_reader :num_samples
    attr_reader :num_features
    attr_reader :problem_struct
    
    attr_reader :data
    attr_reader :options
    
    def self.load_from_csv(csv_path, scale = true, options = {})
      data = CSV.read(csv_path).collect do |row|
        row.collect { |field| field.to_f }
      end
      
      instance = self.new
      
      instance.data = Scaler.scale(data) if scale
      instance
    end

    def initialize(options = {})
      @problem_struct = ProblemStruct.new
      @nodes_pointers = []
      @options        = Options.new(options)
    end
    
    def data=(samples)
      @num_samples  = samples.size
      @num_features = samples.first.size - 1

      problem_struct[:l] = num_samples
      problem_struct[:svm_node] = FFI::MemoryPointer.new(FFI::Pointer, num_samples)
      problem_struct[:y] = FFI::MemoryPointer.new(FFI::Type::DOUBLE, num_samples)

      # Allocate memory for the samples
      # There are num_samples each with num_features nodes 

      num_samples.times.each do |i|
        sample = samples[i].collect(&:to_f)
        
        sample_value = sample.first
        sample_xs    = sample[1..sample.size-1]
        
        problem_struct[:y].put_double(FFI::Type::DOUBLE.size * i, sample_value)
        
        # Allocate memory for the sample
        nodes_ptr = NodeStruct.node_array_from(sample_xs)
        problem_struct[:svm_node].put_pointer(FFI::Pointer.size*i, nodes_ptr)
        
        # We have to keep a reference to the pointer so it is not gargabe collected
        @nodes_pointers << nodes_ptr
      end      
    end
    
    def sample(index)
      sample_ptr = @nodes_pointers[index]
      
      num_features.times.collect do |j|
        node = NodeStruct.new(sample_ptr + NodeStruct.size * j)
        node[:value]
      end
    end

    def value(index)
      problem_struct[:y].get_double(FFI::Type::DOUBLE.size * index)
    end
    
    def length
      problem_struct[:l]
    end
    
    def generate_model(options = {})
      param = param_struct_from(options)
      
      model_pointer = Svm.svm_train(problem_struct.pointer, param.parameter_struct.pointer)
      model_struct = ModelStruct.new(model_pointer)
      
      Model.new(model_struct)
    end
    
    private
    
    def param_struct_from(options)
      param = Options.new(options)
      
      error = Svm.svm_check_parameter(problem_struct, param.parameter_struct)
      raise ParameterError.new("The provided options are not valid: #{error}") if error
      
      param
    end
  end
end