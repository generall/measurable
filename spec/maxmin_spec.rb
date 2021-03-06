describe "Max-min distance" do

  before :all do
    @u = [1, 3, 16]
    @v = [1, 4, 16]
    @w = [4, 5, 6]
  end

  it "accepts two arguments" do
    expect { Measurable.maxmin(@u, @v) }.to_not raise_error
    expect { Measurable.maxmin(@u, @v, @w) }.to raise_error(ArgumentError)
  end

  it "should be symmetric" do
    x = Measurable.maxmin(@u, @v)
    y = Measurable.maxmin(@v, @u)

    expect(x).to be_within(TOLERANCE).of(y)
  end

  it "returns the correct value" do
    x = Measurable.maxmin(@u, @v)

    expect(x).to be_within(TOLERANCE).of(0.9523809523)
  end

  it "raises ArgumentError with vectors of different length" do
    expect { Measurable.maxmin(@u, [1, 3, 5, 7]) }.to raise_error(ArgumentError)
  end

  it "can be extended separately" do
    klass = Class.new do
      extend Measurable::Maxmin
    end
    x = klass.maxmin(@u, @v)

    expect(x).to be_within(TOLERANCE).of(0.9523809523)
  end

  it "can be included separately" do
    klass = Class.new do
      include Measurable::Maxmin
    end
    x = klass.new.maxmin(@u, @v)

    expect(x).to be_within(TOLERANCE).of(0.9523809523)
  end

end
