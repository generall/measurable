module Measurable
  class MVDM
    #
    # Internal class for indexing features occurrence
    #
    class FeatureIndex
      def initialize
        @feature_count = Hash.new(0)
        @feature_label = Hash.new { |hash, key| hash[key] = Hash.new(0) }
      end

      def add_feature(val, label)
        @feature_count[val] += 1
        @feature_label[val][label] += 1
      end

      def probability(feature, label)
        fc = @feature_count[feature]
        fl = @feature_label[feature]
        return 0.0 unless fc || fl
        return fl[label] || 0 / fc.to_f
      end

      # clear all default for Marshall.dump
      def prepare_for_marshalling
        @feature_count.default = nil
        @feature_label.default = nil
        @feature_label.values.each { |ds| ds.default = nil }
      end
    end

    def initialize(data, labels, norm = false)
      @data_size = norm ? data.size.to_f : 1
      @feature_indexes = data.first.size.times.map { FeatureIndex.new }
      @label_count = Hash.new { |hash, key| hash[key] = 0 }
      data.each.with_index do |row, irow|
        row.each.with_index do |x, i|
          fi = @feature_indexes[i]
          label = labels[irow]
          @label_count[label] += 1
          fi.add_feature(x, label)
        end
      end
      @feature_indexes.each(&:prepare_for_marshalling)
      @label_count.default = nil
    end

    # call-seq:
    #     mvdm.distance(first, second) -> Float
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
    # - +first+ -> A sequence of object.
    # - +second+ -> A sequence of object with the same size of +first+.
    # Returns:
    # - sum of difference of conditional probabilities
    #   of label occurrence with given feature for all features.
    #
    # Raises:
    # - +ArgumentError+ -> The sizes of +first+ and +second+ don't match.
    def distance(first, second)
      fail ArgumentError if first.size != second.size
      sz = first.size
      @label_count.keys.reduce(0) do |dist, label|
        dist + sz.times.reduce(0) do |sum, i|
          a = first[i]
          b = second[i]
          fi = @feature_indexes[i]
          sum + (fi.probability(a, label) - fi.probability(b, label)).abs
        end
      end / @data_size
    end
  end
end
