require "svm/version"
require 'ffi'

module Svm
  extend FFI::Library
  ffi_lib "lib/libsvm.so.2"
  
  enum :svm_type, [:c_svc, :nu_svc, :one_class, :epsilon_svr, :nu_svr]
  enum :kernel_type, [:linear, :poly, :rbf, :sigmoid, :precomputed]
  
  class NodeStruct < FFI::Struct
    layout :index, :int,
           :value, :double
    
    def self.node_array_from(sample_xs)
      num_features = sample_xs.size
      
      nodes_ptr = FFI::MemoryPointer.new(NodeStruct, num_features)
      
      num_features.times.each do |j|
        node = NodeStruct.new(nodes_ptr + j * NodeStruct.size)
        node[:index] = j
        node[:value] = sample_xs[j]
      end
      
      nodes_ptr
    end
  end
  
  class ProblemStruct < FFI::Struct
    layout  :l,           :int,
            :y,           :pointer,
            :svm_node,    :pointer
  end
  
  class ParameterStruct < FFI::Struct
    layout :svm_type,     :svm_type,
           :kernel_type,  :kernel_type,
           :degree,       :int,
           :gamma,        :double,
           :coef0,        :double,
           :cache_size,   :double,
           :eps,          :double,
           :c,            :double,
           :nr_weight,    :int,
           :weight_label, :pointer,
           :weight,       :pointer,
           :nu,           :double,
           :p,            :double,
           :shrinking,    :int,
           :probability,  :int    
  end
  
  class ModelStruct < FFI::Struct
    layout :param_ptr,   :pointer,
           :nr_class,    :int,
           :l,           :int,
           :node_ptr,    :pointer,
           :sv_coef_ptr, :pointer,
           :rho_ptr,     :pointer,
           :probA_ptr,   :pointer,
           :probB_ptr,   :pointer,
           :labels_ptr,  :pointer,
           :nSV_ptr,     :pointer,
           :free_sv,     :int
  end
  
  attach_function 'svm_train', [:pointer, :pointer], :pointer
  
  attach_function 'svm_cross_validation', [:pointer, :pointer, :int, :pointer], :void
  attach_function 'svm_save_model', [:string, :pointer], :int
  attach_function 'svm_load_model', [:string], :pointer
  attach_function 'svm_get_svm_type', [:pointer], :int
  attach_function 'svm_get_nr_class', [ :pointer], :int
  attach_function 'svm_get_labels', [:pointer, :pointer], :void
  attach_function 'svm_get_svr_probability', [:pointer], :double
  
  attach_function 'svm_predict_values', [:pointer, :pointer, :pointer], :double
  attach_function 'svm_predict', [:pointer, :pointer], :double
  attach_function 'svm_predict_probability', [:pointer, :pointer, :pointer], :double
  
  attach_function 'svm_free_model_content', [:pointer], :void
  attach_function 'svm_free_and_destroy_model', [:pointer], :void
  attach_function 'svm_destroy_param', [:pointer], :void
  
  attach_function 'svm_check_parameter', [:pointer, :pointer ], :string
  attach_function 'svm_check_probability_model', [:pointer,], :int
end

require_relative 'svm/options'
require_relative 'svm/problem'
require_relative 'svm/model'
