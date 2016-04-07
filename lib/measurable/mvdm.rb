module Measurable
  module Probabilities
    #
    # Internal class for indexing features occurrence
    #
    class FeatureIndex
      attr_accessor :feature_label, :feature_count
      def initialize
        @feature_count = Hash.new(0)
        @feature_label = Hash.new { |hash, key| hash[key] = Hash.new(0) }
        @total_count = 0
      end

      def add_feature(val, label)
        @feature_count[val] += 1
        @feature_label[val][label] += 1
        @total_count += 1
      end

      # calculate conditional probability
      # P( +label+ | +feature+ )
      def probability(feature, label)
        fc = @feature_count[feature]
        fl = @feature_label[feature]
        return 0.0 unless fc || fl
        return (fl[label] || 0.0) / fc.to_f
      end

      # calculate entropy of feature
      def entropy
        - @feature_count.reduce(0.0) do |sum, pair|
          value = pair[0]
          count = pair[1]
          prob = count / @total_count.to_f
          sum + prob * Math::log(prob, 2) 
        end
      end

      # clear all default for Marshall.dump
      def prepare_for_marshalling
        @feature_count.default = nil
        @feature_label.default = nil
        @feature_label.values.each { |ds| ds.default = nil }
      end
    end
  end
  class MVDM

    # computes matrix for [feature, feature] summed over all labels
    def pre_compute_distance_matrix
      @distance_matrix = Hash.new()
      @feature_indexes.each.with_index do |feature_index, key|
        @distance_matrix[key] = Hash.new(0.0)
        indexes = feature_index.feature_count.keys.product(feature_index.feature_count.keys)
        indexes.each do |index|
          a = index[0]
          b = index[1]
          @distance_matrix[key][index] = @label_count.keys.reduce(0) do |dist, label|
            dist + (feature_index.probability(a, label) - feature_index.probability(b, label)).abs
          end / @data_size
        end
      end
    end


    # +data+ - is array of data to learn
    # +labels+ - is corresponding to dataset targer label of class
    # +norm+ - is normalisation flag
    def initialize(data, labels, options = {})
      @data_size = options[:norm] ? data.size.to_f : 1
      return if data.empty?
      @feature_indexes = data.first.size.times.map { Probabilities::FeatureIndex.new }
      @label_count = Hash.new { |hash, key| hash[key] = 0 }
      data.each.with_index do |row, irow|
        label = labels[irow]
        @label_count[label] += 1
        row.each.with_index do |x, i|
          fi = @feature_indexes[i]
          fi.add_feature(x, label)
        end
      end
      pre_compute_distance_matrix
      @feature_indexes.each(&:prepare_for_marshalling)
      @label_count.default = nil
    end

    # call-seq:
    #     mvdm.distance(obj1, obj2) -> Float
    #
    # Calculate difference of conditional probabilities
    #   of label occurrence with given feature.
    #
    # Return sum of differences for all features in input datum.
    #
    # See: Cost, Scott, and Steven Salzberg.
    # "A weighted nearest neighbor algorithm for learning
    #   with symbolic features." Machine learning 10.1 (1993): 57-78.
    #
    # Arguments:
    # - +obj1+ -> A sequence of object.
    # - +obj2+ -> A sequence of object with the same size of +obj1+.
    # Returns:
    # - sum of difference of conditional probabilities
    #   of label occurrence with given feature for all features.
    #
    # Raises:
    # - +ArgumentError+ -> The sizes of +obj1+ and +obj2+ don't match.
    def distance(obj1, obj2)
      fail ArgumentError if obj1.size != obj2.size
      fail ArgumentError if obj1.size != @distance_matrix.size
      @distance_matrix.reduce(0.0) do |sum, pair|
        key  = pair[0]
        dist = pair[1]
        sum + dist[[obj1[key], obj2[key]]]
      end
    end
  end
end
