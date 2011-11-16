module Svm
  module CrossValidation
    
    def accuracy_for_cross_validation(n_folds = 5, custom_options = nil)
      results = cross_validate(n_folds, custom_options)
      
      num_samples.times.count { |i| value(i) == results[i] }.to_f/num_samples
    end
    
    def cross_validate(n_folds = 5, more_options = nil)
      set(more_options) if more_options
      
      predicted_results_pointer = FFI::MemoryPointer.new(:double, num_samples)
      
      Svm.svm_cross_validation(problem_struct, options.parameter_struct, n_folds, predicted_results_pointer)
      
      predicted_results_pointer.read_array_of_double(num_samples)
    end
    
    def find_best_parameters(n_folds = 5)
      c_exponents = (-5..15).to_a
      gamma_exponents = (-15..3).to_a
      
      combinations = c_exponents.product(gamma_exponents)
      
      max = combinations.max_by do |comb|
        c = 2 ** comb[0]
        gamma = 2 ** comb[1]
        
        accuracy_for_cross_validation(n_folds, :c => c, :gamma => gamma)
      end
      
      c     = 2**max[0]
      gamma = 2**max[1]
      
      {:c => c, :gamma => gamma}
    end
  end
end