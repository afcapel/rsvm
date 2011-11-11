module Svm
  class ModelSerializationError < StandardError; end
  
  class Model
    attr_reader :model_struct
    
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
    
    def predict(sample)
      nodes_ptr = NodeStruct.node_array_from(sample)
      Svm.svm_predict(model_struct, nodes_ptr)
    end
  end
end