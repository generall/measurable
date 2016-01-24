module Measurable
  class MVDM
    #
    # Internal class for indexing features occurrence
    #
    class FeatureIndex
      def initialize()
        @feature_count = Hash.new { |hash, key| hash[key] = 0 }
        @feature_label = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = 0 } }
      end

      def add_feature(val, label)
        @feature_count[val] += 1;
        @feature_label[val][label] += 1;
      end

      def probabilityFeatureLabel(feature, label)
        fc = @feature_count[feature]
        fl = @feature_label[feature]
        return 0.0 if !(fc || fl)
        return fl[label] || 0 / fc.to_f
      end

      # clear all default_proc for Marshall.dump
      def prepDump()
        @feature_count.default_proc = nil
        @feature_label.default_proc = nil
        @feature_label.values.each {|ds| ds.default_proc = nil}
      end
    end

    def initialize(data, labels, norm = false)
      @data_size = norm ? data.size.to_f : 1;
      @feature_indexes = data.first.size.times.map{ FeatureIndex.new() }
      @label_count = Hash.new { |hash, key| hash[key] = 0 }
      data.each.with_index do |row, irow|
        row.each.with_index do |x, i|
          fi = @feature_indexes[i]
          label = labels[irow]
          @label_count[label] += 1;
          fi.add_feature(x, label)
        end
      end
      @feature_indexes.each{|x| x.prepDump}
      @label_count.default_proc = nil
    end


    # call-seq:
    #     hamming(first, second) -> Float
    #
    # Calculate difference of conditional probabilities of label occurrence with given feature.
    # Return sum of differences for all features in input datum.
    #
    # See: Cost, Scott, and Steven Salzberg. "A weighted nearest neighbor algorithm for learning with symbolic features." Machine learning 10.1 (1993): 57-78.
    #
    # Arguments:
    # - +first+ -> A sequence of object.
    # - +second+ -> A sequence of object with the same size of +first+.
    # Returns:
    # - sum of difference of conditional probabilities of label occurrence with given feature for all features.
    # Raises:
    # - +ArgumentError+ -> The sizes of +first+ and +second+ don't match.
    def distance(first, second)
      raise ArgumentError if first.size != second.size
      sz = first.size
      @label_count.keys.reduce(0) do |dist, label|
        dist + sz.times.reduce(0) do |sum, i|
          a = first[i]
          b = second[i]
          fi = @feature_indexes[i]
          sum + (fi.probabilityFeatureLabel(a, label) - fi.probabilityFeatureLabel(b, label)).abs
        end
      end / @data_size
    end
  end
end