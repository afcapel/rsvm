# RSVM
[![Build Status](https://secure.travis-ci.org/afcapel/rsvm.png)](http://travis-ci.org/afcapel/rsvm)

RSVM is a Ruby gem to perform Support Vector Machine classification and regresion
in Ruby. It is FFI wrapper of libsvm.

## Usage

```ruby
problem = Svm::Problem.new

# These are the training samples. The first element in each array is the label
# for the sample, the rest is the sample coordinates.

problem.data = [
  [1, 1, 0, 1],
  [-1, -1, 0, -1]
]

# Generate a model from this problem

model = problem.generate_model(:kernel_type => :linear, :c => 10)

# And make predictions

model.predict([-1, 0, -1]) # - 1
model.predict([1,  0,  1]) # 1

# Models can be saved to a file

model.save(file.path)

loaded_model = Svm::Model.load(file.path)

loaded_model.predict([-1, 0, -1]) # -1
loaded_model.predict([1,  0,  1]) # 1
```

## Load data from csv

```ruby
csv_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'heart_scale.csv')
problem = Svm::Problem.load_from_csv(csv_path)
```

## Scaling data

For the Support Vector Machine to perform well the features in the samples data must
be of the same order of magnitude. RSVM can scale your data linearly to the [-1, 1] range.

```ruby
data = [
  [1, 12.0, -7.6, 100_000, 0],
  [2, 30.0, 0, -100_000, 0],
  [3, 36.0, 7.6, 0, 0]
]

problem = Svm::Problem.new(data, scale: true)

```

## Estimate probabilities

You can also estimate probabilities for the diferent labels.

```ruby

problem.estimate_probabilities = true
model = problem.generate_model

sample = [60.0, 1.0, 3.0, 140.0, 185.0, 0.0, 2.0, 155.0, 0.0, 3.0, 2.0, 0.0, 3.0]
probs = model.predict_probabilities(sample)

# Return a hash with the probabilities associated with the sample
# {1=>0.4443737921739047, -1=>0.5556262078260953}
```

## Find parameters doing grid search

If you are not sure which parameters to use in your problem RSVM can do a simple grid search
to find the parameters that perform better doing crossvalidation.

```ruby
problem = Svm::Problem.load_from_csv(UNBALANCED_CSV)
n_folds = 3

# This will perform a grid search using each combination with c from 2^1 up to 2^14
# and gamma from 2^-13 up to 2^-1. For each combination it will use crossvalidation
# using 3 folds.

options = problem.find_best_parameters(n_folds)

# Result:
# {:c=>64, :gamma=>(1/128)}
```


