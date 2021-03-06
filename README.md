# Measurable

[![Build Status](https://travis-ci.org/agarie/measurable.svg?branch=master)](https://travis-ci.org/agarie/measurable)
[![Code Climate](https://codeclimate.com/github/agarie/measurable.png)](https://codeclimate.com/github/agarie/measurable)

A gem to test what metric is best for certain kinds of datasets in machine
learning. Besides the `Array` class, I also want to support
[NMatrix](http://github.com/sciruby/nmatrix).

This is a fork of the gem [Distance Measure](https://github.com/reddavis/Distance-Measures),
which has a similar objective, but isn't actively maintained and doesn't support
NMatrix. Thank you, [@reddavis][reddavis]. :)

## Installation

`gem install measurable`

This gem is currently being tested on MRI Ruby 1.9.3, 2.0, 2.1.0, 2.1 (HEAD) and on Rubinius 2.x (HEAD). I hope to add JRuby support in the future.

## Available distance measures

I'm using the term "distance measure" without much concern for the strict
mathematical definition of a metric. If the documentation for one of the
methods isn't clear about it being or not a metric, please open an issue.

The following are the similarity measures supported at the moment:

- Euclidean distance
- Squared euclidean distance
- Cosine distance
- Max-min distance (from ["K-Means clustering using max-min distance measure"][maxmin])
- Jaccard distance
- Tanimoto distance
- Haversine distance
- Minkowski (aka Cityblock or Manhattan) distance
- Chebyshev distance
- Hamming distance
- [Levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance)
- [Kullback-Leibler divergence](http://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence)
- Modified Value Difference Metric (MVDM)
- Weighted overlap with Information Gain and Information Gain Ratio

## How to use

The API I intend to support is something like this:

```ruby
require 'measurable'

# Calculate the distance between two points in space.
Measurable.euclidean([1, 1], [0, 0]) # => 1.41421

# Calculate the norm of a vector, i.e. its distance from the origin.
Measurable.euclidean([1, 1]) # => 1.4142135623730951

# Get the cosine distance between
Measurable.cosine_distance([1, 2], [2, 3]) # => 0.007722123286332261

# Calculate sum of squares directly.
Measurable.euclidean_squared([3, 4]) # => 25
```

Most of the methods accept arbitrary enumerable objects instead of Arrays. For example, it's possible to use [NMatrix](https://github.com/sciruby/nmatrix).

Yoy can use `Measurable::MeasurableObject` mixin to make your own object measurable.
You can also use distance function like object. For example, you can pass distance function to some classification algorithm.

```ruby
class String
	# including mixin
	include Measurable::MeasurableObject
	# This function returns measurable object (Array, NMatrix, Enumerable, e.t.c)
	def coordinates
		self
	end
end
# Strings are measurable now!
s1 = 'string1'
s2 = 'string2'
# Setting up measure to use
s1.measure = Measurable.object_for(:hamming)
s1.distance s2
# => 1
```

## Documentation

The documentation is hosted on [rubydoc](http://www.rubydoc.info/github/agarie/measurable).

## License

See LICENSE for details.

The original `distance_measures` gem is copyrighted by [@reddavis][reddavis].

[maxmin]: http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=05156398
[reddavis]: (https://github.com/reddavis)
