module Svm
  module Debug
    
    def debug
      defined?(@debug) && @debug
    end

    def debug=(do_debug)
      @debug = do_debug
    end
  end
end