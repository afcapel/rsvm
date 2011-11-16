module Svm
  class ModelSerializationError < StandardError; end
  class ModelError < StandardError; end
  
  class Model
    attr_reader   :model_struct
    attr_accessor :scaler
    
    def initialize(model_struct)
      @model_struct = model_struct
    end
    
    def save(path)
      result = Svm.svm_save_model(path, model_struct.pointer)
      raise ModelSerializationError.new("Unable to save model to file. Error: #{result}") unless result == 0
    end
    
    def self.load(path)
      model_struct_pointer = Svm.svm_load_model(path)
      raise ModelSerializationError.new("Unable to load model from file. Error: #{result}") unless model_struct_pointer != FFI::Pointer::NULL
      
      model_struct = ModelStruct.new(model_struct_pointer)
      self.new(model_struct)
    end
    
    def number_of_classes
      Svm.svm_get_nr_class(model_struct)
    end
    
    def labels
      labels_array = FFI::MemoryPointer.new(:int, number_of_classes)
      
      Svm.svm_get_labels(model_struct, labels_array)
      
      labels_array.read_array_of_int(number_of_classes)
    end
    
    def predict(sample)
      scaler.scale(sample) if scaler
      
      nodes_ptr = NodeStruct.node_array_from(sample)
      Svm.svm_predict(model_struct, nodes_ptr)
    end
    
    def predict_probabilities(sample)
      unless Svm.svm_check_probability_model(model_struct) == 1
        raise ModelError.new("Model doesn't have probability info")
      end
      
      scaler.scale(sample) if scaler
      
      nodes_ptr = NodeStruct.node_array_from(sample)
      
      prob_array = FFI::MemoryPointer.new(:double, number_of_classes)
      
      Svm.svm_predict_probability(model_struct, nodes_ptr, prob_array)
      probabilities = prob_array.read_array_of_double(number_of_classes)
      
      number_of_classes.times.inject({}) do |hash, index|
        label = labels[index]
        prob  = probabilities[index]
        
        hash[label] = prob
        hash
      end
    end
  end
end