module Svm
  module CrossValidation
    
    def accuracy_for_cross_validation(n_folds = 5, options = {})
      results = cross_validate(n_folds, options)
      
      num_samples.times.count { |i| value(i) == results[i] }.to_f/num_samples
    end
    
    def cross_validate(n_folds = 5, options = {})
      param = param_struct_from(options)
      predicted_results_pointer = FFI::MemoryPointer.new(:double, num_samples)
      
      Svm.svm_cross_validation(problem_struct.pointer, param.parameter_struct.pointer, n_folds, predicted_results_pointer)
      
      num_samples.times.inject([]) do |arr, i|
        result =  predicted_results_pointer.get_double(FFI::Type::DOUBLE.size * i)
        arr << result
        arr
      end
    end
    
    def find_best_parameters
      c_exponents = (1..5).to_a
      gamma_exponents = (-5..3).to_a
      
      combinations = c_exponents.product(gamma_exponents)
      
      max = combinations.max_by do |comb|
        c = 10 ** comb[0]
        gamma = 10 ** comb[1]
        
        accuracy_for_cross_validation(5, :c => c, :gamma => gamma)
      end
      
      c     = 10**max[0]
      gamma = 10**max[1]
      
      {:c => c, :gamma => gamma}
    end
  end
end