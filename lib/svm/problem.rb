require 'csv'

module Svm
  class Problem
    include CrossValidation
    
    attr_reader :num_samples
    attr_reader :num_features
    attr_reader :options
    
    attr_accessor :scaler
    
    def self.load_from_csv(csv_path, options = {})
      data = CSV.read(csv_path).collect do |row|
        row.collect { |field| field.to_f }
      end
      
      instance = self.new(options)
      instance.data = data
      
      instance
    end

    def initialize(user_options = {})
      @nodes_pointers = []
      @options = Options.new(user_options)
    end
    
    def data=(samples)
      @num_samples  = samples.size
      @num_features = samples.first.size - 1
      
      if options[:scale]
        self.scaler = Scaler.scale(samples)
        scaler.release_data!
      end
      
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
    
    def generate_model(more_options = {})
      set(more_options)
            
      model_pointer = Svm.svm_train(problem_struct.pointer, options.parameter_struct.pointer)
      model_struct = ModelStruct.new(model_pointer)
      
      model = Model.new(model_struct)
      model.scaler = scaler
      
      model
    end
    
    def suggested_labels_weights
      labels.inject({}) do |hash, label|
        num = num_samples_for(label).to_f
        hash[label.to_i] = num/num_samples
        hash
      end
    end
    
    def num_samples_for(label)
      num_samples.times.count { |i| value(i) == label }
    end
    
    def labels
      num_samples.times.collect { |i| value(i) }.uniq
    end
    
    def label_weights=(weights)
      options.label_weights = weights
      check_parameters!
    end
    
    def weight_for(label)
      options.weights[label] || 1.0
    end
    
    def estimate_probabilities=(option)
      value = option ? 1 : 0
      
      options.parameter_struct[:probability] = value
    end
    
    def set(custom_options)
      options.add(custom_options)
      check_parameters!
    end
    
    private
    
    def problem_struct
      @problem_struct ||= ProblemStruct.new
    end
    
    def check_parameters!
      error = Svm.svm_check_parameter(problem_struct, options.parameter_struct)
      raise ParameterError.new("The provided options are not valid: #{error}") if error
    end

  end
end