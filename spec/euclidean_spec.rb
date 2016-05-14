describe "Euclidean" do

  before :all do
    @u = [1, 3, 16]
    @v = [1, 4, 16]
    @w = [4, 5, 6]
  end

  context "Distance" do
    it "accepts two arguments" do
      expect { Measurable.euclidean(@u, @v) }.to_not raise_error
      expect { Measurable.euclidean(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it "accepts one argument and returns the vector's norm" do
      # Remember that 3^2 + 4^2 = 5^2.
      expect(Measurable.euclidean([3, 4])).to eq 5
    end

    it "should be symmetric" do
      expect(Measurable.euclidean(@u, @v)).to eq Measurable.euclidean(@v, @u)
    end

    it "should return the correct value" do
      expect(Measurable.euclidean(@u, @u)).to eq 0
      expect(Measurable.euclidean(@u, @v)).to eq 1
    end

    it "raises ArgumentError with vectors of different length" do
      expect { Measurable.euclidean(@u, [2, 2, 2, 2]) }.to raise_error(ArgumentError)
    end

    it "can be extended separately" do
      klass = Class.new do
        extend Measurable::Euclidean
      end

      expect(klass.euclidean([3, 4])).to eq 5
    end

    it "can be included separately" do
      klass = Class.new do
        include Measurable::Euclidean
      end

      expect(klass.new.euclidean([3, 4])).to eq 5
    end
  end

  context "Squared Distance" do
    it "accepts two arguments" do
      expect { Measurable.euclidean_squared(@u, @v) }.to_not raise_error
      expect { Measurable.euclidean_squared(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it "accepts one argument and returns the vector's norm" do
      # Remember that 3^2 + 4^2 = 5^2.
      expect(Measurable.euclidean_squared([3, 4])).to eq 25
    end

    it "should be symmetric" do
      x = Measurable.euclidean_squared(@u, @v)
      y = Measurable.euclidean_squared(@v, @u)

      expect(x).to eq y
    end

    it "should return the correct value" do
      expect(Measurable.euclidean_squared(@u, @u)).to eq 0
      expect(Measurable.euclidean_squared(@u, @v)).to eq 1
    end

    it "raises ArgumentError with vectors of different length" do
      expect { Measurable.euclidean_squared(@u, [2, 2, 2, 2]) }.to raise_error(ArgumentError)
    end
  end
end
