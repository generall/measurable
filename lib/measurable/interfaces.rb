module Measurable
  module Interface
    class DistanceByName
      def initialize(name)
        @name = name
      end

      def distance(a, b)
        Measurable.send(@name, a, b)
      end
    end
    def object_for(measure)
      DistanceByName.new(measure)
    end
  end

  extend Measurable::Interface

  module MeasurableObject
    # Mixin to add ability for any object,
    # which implements coordinates,
    # to calc distance with 'distance' function
    def distance(other, measure = nil, &distance)
      if distance
        yield coordinates, other.coordinates
      else
        if measure
          measure.distance(coordinates, other.coordinates)
        else
          if @measure
            @measure.distance(coordinates, other.coordinates)
          else
            throw 'No measure specified'
          end
        end
      end
    end

    attr_accessor :measure
  end
end

# Make Array to be Measurable. Coorinates of Array is Array itself.
class Array
  include Measurable::MeasurableObject

  def coordinates
    self
  end
end
