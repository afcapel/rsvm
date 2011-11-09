module Svm
  class Problem
    attr_reader :num_samples
    attr_reader :num_features
    attr_reader :problem_struct

    def initialize(samples)
      @problem_struct = ProblemStruct.new

      @num_samples  = samples.size
      @num_features = samples[0][0].size

      problem_struct[:length] = num_samples
      problem_struct[:samples_ptr] = FFI::MemoryPointer.new(FFI::Pointer.size, num_samples)
      problem_struct[:y] = FFI::MemoryPointer.new(FFI::Type::DOUBLE, num_samples)

      # Allocate memory for the samples
      # There are num_samples each with num_features nodes

      @nodes_ptr = FFI::MemoryPointer.new(NodeStruct, num_samples * num_features)

      num_samples.times.each do |i|
        sample_xs = samples[i].first
        @problem_struct[:y].put_double(FFI::Type::DOUBLE.size * i, samples[i][1])

        num_features.times.each do |j|
          node = NodeStruct.new(@nodes_ptr + (NodeStruct.size * num_features * i) + (NodeStruct.size * j))
          node[:index] = j
          node[:value] = sample_xs[j]
        end
      end
    end

    def sample_pointer(index)
      FFI::Pointer.new(problem_struct[:samples_ptr] + FFI::Pointer.size * index)
    end

    def value(index)
      problem_struct[:y].get_double(FFI::Type::DOUBLE.size * index)
    end

    def sample(index)
      num_features.times.collect do |j|
        node = NodeStruct.new(@nodes_ptr + (NodeStruct.size * num_features * index) + (NodeStruct.size * j))
        node[:value]
      end
    end
  end
end