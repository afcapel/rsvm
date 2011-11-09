module Svm
  class Node < FFI::Struct
    layout :index, :int,
           :value, :double
  end
end