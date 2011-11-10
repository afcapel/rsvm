module Svm
  class ParameterError < StandardError; end
    
  class Problem
    attr_reader :num_samples
    attr_reader :num_features
    attr_reader :problem_struct

    def initialize(samples)
      @problem_struct = ProblemStruct.new

      @num_samples  = samples.size
      @num_features = samples.first.size - 1

      problem_struct[:l] = num_samples
      problem_struct[:svm_node] = FFI::MemoryPointer.new(FFI::Pointer, num_samples)
      problem_struct[:y] = FFI::MemoryPointer.new(FFI::Type::DOUBLE, num_samples)

      # Allocate memory for the samples
      # There are num_samples each with num_features nodes 

      num_samples.times.each do |i|
        sample = samples[i].dup.to_a
        
        sample_value = sample.first.to_f
        sample_xs    = sample[1..sample.size-1]
        
        
        problem_struct[:y].put_double(FFI::Type::DOUBLE.size * i, sample_value)
        
        # Allocate memory for the sample
        nodes_ptr = NodeStruct.node_array_from(sample_xs)
        problem_struct[:svm_node].put_pointer(FFI::Pointer.size*i, nodes_ptr)
      end
    end

    def sample_pointer(index)
      (problem_struct[:svm_node] + FFI::Pointer.size * index).get_pointer(0)
    end

    def value(index)
      problem_struct[:y].get_double(FFI::Type::DOUBLE.size * index)
    end
    
    def length
      problem_struct[:l]
    end

    def sample(index)
      sample_ptr = sample_pointer(index)
      
      num_features.times.collect do |j|
        node = NodeStruct.new(sample_ptr + NodeStruct.size * j)
        node[:value]
      end
    end
    
    def generate_model(options = {})
      param = Options.new(options)
      
      error = Svm.svm_check_parameter(problem_struct, param.parameter_struct)
      raise ParameterError.new("Error while training model. The parameters are not valid: #{error}") if error 
      
      model_pointer = Svm.svm_train(problem_struct.pointer, param.parameter_struct.pointer)
      model_struct = ModelStruct.new(model_pointer)
      
      Model.new(model_struct)
    end
  end
end