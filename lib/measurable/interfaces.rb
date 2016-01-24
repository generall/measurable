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
    def getObject(measure)
      DistanceByName.new(measure)
    end
  end

  extend Measurable::Interface

  module MeasurableObject
    # Mixin to add ability for any object,
    # which implements coords,
    # to calc distance with 'calc_distance' function
    def distance(other, measure = nil, &distance)
      if distance
        yield self.coords, other.coords
      else
        if measure
          # it performs many str cmp =(
          measure.distance(self.coords, other.coords)
        else
          if @measure
            @measure.distance(self.coords, other.coords)
          else
            throw "No measure specified"
          end
        end
      end
    end

    attr_accessor :measure
    
  end
end


class Array
  include Measurable::MeasurableObject

  def coords
    self
  end
end
