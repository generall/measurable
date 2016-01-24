describe "Interface for distance functions" do

  before :all do
    @u = "Hi, I'm a test string!"
    @v = "Hello, not a test omg."
    @x = [1,1]
    @y = [2,2]
  end

  it "create object from measure label" do
    obj = nil
    expect { obj = Measurable.getObject(:euclidean) }.to_not raise_error
  end

  it "should calc euclidean distance" do
    obj = Measurable.getObject(:euclidean)
    d = @x.distance(@y, obj)
    d.should be(2**(0.5))
  end

  it "should calc overlap distance" do
    d = @x.distance(@y){ |x| x.reduce(0){ |sum, a| sum + (a[0] - a[1]).abs } }
    d.should be(2)
  end

  it "should calc hamming distance with string" do
    # Extending string to be measurable
    class String
      include Measurable::MeasurableObject
      def coords
        self
      end
    end
    @u.measure = Measurable.getObject(:hamming)
    d = @u.distance(@v)
    d.should be(17)
  end

  it "should create measure object" do
    mClass = Class.new do
      include Measurable::Euclidean
      alias :distance :euclidean
    end
    obj = mClass.new
    @x.measure = obj
    d = @x.distance @y
    d.should be(2**0.5)
  end
end
