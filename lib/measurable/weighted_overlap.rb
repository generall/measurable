module Measurable
  class WeightedOverlap

    attr_accessor :weights, :feature_indexes

    def conditional_entropy(feature_index, feature_value)
      # H(label | feature) = \Sum_{l \in Labels} P(l | feature) log P(l | feature)
      - @label_count.reduce(0.0) do |sum, pair|
        label = pair[0]
        count = pair[1]
        # P(l | feature) = count of (Label = l) / count of (Feature = f)
        prob = feature_index.probability(feature_value, label)
        if prob != 0.0
          sum += prob * Math::log(prob, 2)
        end
        sum
      end
    end

    def information_gain(feature_index)
      # for each feature value weighted by feature probability
      label_entropy - feature_index.feature_count.reduce(0.0) do |sum, pair|
        feature = pair[0]
        count = pair[1]
        sum + conditional_entropy(feature_index, feature) * count
      end / @data_size.to_f
    end

    def label_entropy()
      unless @label_entropy_cahce
        @label_entropy_cahce = - @label_count.reduce(0.0) do |sum, pair|
          label = pair[0]
          count = pair[1]
          prob = count / @data_size.to_f
          sum += prob * Math::log(prob, 2)
        end
      end
      @label_entropy_cahce
    end

    def initialize(data = nil, labels = nil)
      # if distance is not initialized with data - all weights are equal to 1.
      return unless data && labels # do nothing if no data provided
      fail ArgumentError if data.size != labels.size

      @weights = Hash.new(1.0)
      @data_size  = data.size
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

      @feature_indexes.each.with_index do |feature_index, index|
        @weights[index] = information_gain(feature_index)
      end

      # determine feature count
      # calc information gain for each feature and save it.
      @feature_indexes.each(&:prepare_for_marshalling)
      @label_count.default = nil
    end

    def distance(obj1, obj2)
      fail ArgumentError if obj1.size != obj2.size
      obj1.zip(obj2).each.with_index.reduce(0.0) do |sum, data|
        a = data.first[0]
        b = data.first[1]
        i = data.last
        sum + (a == b ? @weights[i] : 0.0)
      end
    end
  end
end
