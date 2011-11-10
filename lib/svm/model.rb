module Svm
  class Model
    attr_reader :model_struct
    
    def initialize(model_struct)
      @model_struct = model_struct
    end
    
    def predict(sample)
      nodes_ptr = NodeStruct.node_array_from(sample)
      Svm.svm_predict(model_struct, nodes_ptr)
    end
  end
end