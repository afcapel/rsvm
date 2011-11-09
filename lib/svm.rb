require "svm/version"
require 'ffi'

module Svm
  extend FFI::Library
  ffi_lib "lib/libsvm.so.2"
end

require_relative 'svm/node'