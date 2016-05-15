describe "Minkowski" do
  before :all do
    @u = [1, 3, 6]
    @v = [1, 4, 7]
    @w = [4, 5, 6]
  end

  context "Distance" do
    it "accepts two arguments" do
      expect { Measurable.minkowski(@u, @v) }.to_not raise_error
      expect { Measurable.minkowski(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it "should be symmetric" do
      expect(Measurable.minkowski(@u, @v)).to eq Measurable.minkowski(@v, @u)
    end

    it "returns the correct value" do
      expect(Measurable.minkowski(@u, @u)).to eq 0
      expect(Measurable.minkowski(@u, @v)).to eq 2
    end

    it "shouldn't work with vectors of different length" do
      expect { Measurable.minkowski(@u, [2, 2, 2, 2]) }.to raise_error(ArgumentError)
    end

    it "can be extended separately" do
      klass = Class.new do
        extend Measurable::Minkowski
      end

      expect(klass.minkowski(@u, @u)).to eq 0
    end

    it "can be included separately" do
      klass = Class.new do
        include Measurable::Minkowski
      end

      expect(klass.new.minkowski(@u, @u)).to eq 0
    end
  end
end
