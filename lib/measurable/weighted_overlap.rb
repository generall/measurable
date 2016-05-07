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
        value = pair[0]
        count = pair[1]
        sum + conditional_entropy(feature_index, value) * count
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

    def initialize(data = nil, labels = nil, options = {})
      # if distance is not initialized with data - all weights are equal to 1.
      @weights = Hash.new(1.0)
      return unless data && labels # do nothing if no data provided
      return if data.empty? || labels.empty?
      fail ArgumentError if data.size != labels.size

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

      if options[:skip_weighting]
        @feature_indexes.each.with_index do |feature_index, index|
          @weights[index] = 1.0
        end
      else
        @feature_indexes.each.with_index do |feature_index, index|
          @weights[index] = information_gain(feature_index)
        end

        if options[:ratio]
          @weights.each do |key, w|
            feature_index = @feature_indexes[key]
            entropy = feature_index.entropy
            w /= entropy if w.abs > 1e-9
            @weights[key] = w
          end
        end
      end

      # determine feature count
      # calc information gain for each feature and save it.
      @feature_indexes.each(&:prepare_for_marshalling)
      @label_count.default = nil
    end

    # calculate distance dontribution by features +f1+ and +f2+ with index +idx+
    def feature_contribution(f1, f2, idx)
      weight = @weight[idx]
      dist = f1 != f2 ? weight : 0.0;
    end

    # call-seq:
    #     weighted_overlap.distance(obj1, obj2) -> Float
    #
    # Calculate weighted similarity between +obj1+ and +obj2+.
    # Weights are calculated like Information Gain.
    #
    #
    # Return weighted sum of differences for all features in input datum.
    #
    # @inproceedings{kira1992practical,
    #   title={A practical approach to feature selection},
    #   author={Kira, Kenji and Rendell, Larry A},
    #   booktitle={Proceedings of the ninth international workshop on Machine learning},
    #   pages={249--256},
    #   year={1992}
    # }
    #
    # Arguments:
    # - +obj1+ -> A sequence of object.
    # - +obj2+ -> A sequence of object with the same size of +obj1+.
    # Returns:
    # - weighted sum of difference of overlap for all features.
    #
    # Raises:
    # - +ArgumentError+ -> The sizes of +obj1+ and +obj2+ don't match.
    def distance(obj1, obj2)
      fail ArgumentError if obj1.size != obj2.size
      obj1.zip(obj2).each.with_index.reduce(0.0) do |sum, data|
        a = data.first[0]
        b = data.first[1]
        i = data.last
        sum + (a != b ? @weights[i] : 0.0)
      end
    end
  end
end
