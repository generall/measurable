describe "Hamming distance" do

  before :all do
    @u = "Hi, I'm a test string!"
    @v = "Hello, not a test omg."
    @w = "Hey there, a test wtf!"
  end

  it "accepts two arguments" do
    expect { Measurable.hamming(@u, @v) }.to_not raise_error
  end

  it 'raises ArgumentError with three arguments' do
    expect { Measurable.hamming(@u, @v, @w) }.to raise_error(ArgumentError)
  end

  it "should be symmetric" do
    x = Measurable.hamming(@u, @v)
    y = Measurable.hamming(@v, @u)

    expect(x).to be(y)
  end

  it "should return the correct value" do
    x = Measurable.hamming(@u, @v)
    expect(x).to be(17)
  end

  it "raises ArgumentError with strings of different length" do
    expect { Measurable.hamming(@u, "smallstring") }.to raise_error(ArgumentError)
    expect { Measurable.hamming(@u, "largestring" * 20) }.to raise_error(ArgumentError)
  end

  it "can be extended separately" do
    klass = Class.new do
      extend Measurable::Hamming
    end

    expect(klass.hamming(@u, @v)).to eq 17
  end

  it "can be included separately" do
    klass = Class.new do
      include Measurable::Hamming
    end

    expect(klass.new.hamming(@u, @v)).to eq 17
  end
end
