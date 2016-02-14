describe "MVDM distance" do

  before :all do
    @data = [
      [5,6,8],
      [6,8,8],
      [7,4,1],
      [6,6,7],
      [3,3,9],
      [1,3,2],
      [7,6,2],
      [2,6,5],
      [8,6,8],
      [4,7,2],
      [4,6,2],
      [2,3,1],
      [5,8,1],
      [9,9,4],
      [7,8,5],
      [5,8,9],
      [6,8,2],
      [2,9,6],
      [6,8,6],
      [7,1,9],
      [2,2,1],
      [8,5,6],
      [1,9,4],
      [1,2,5]
    ]

    @labels = @data.map{|x| x.map{|y| y.odd? ? 1 : 0}.reduce(:+) > 1 ? :odd : :nodd }

    @test = [
      [[1,1,1], [2,2,2]],
      [[1,1,1], [2,8,4]],
      [[1,1,1], [3,3,3]],
      [[1,1,1], [3,9,7]]
    ]
  end

  it "can be dumped and restored" do
    expect do
      metric = Measurable::MVDM.new(@data, @labels)
      dump = Marshal.dump(metric)
      metric = Marshal.load(dump)
    end.to_not raise_error
  end

  it "should calc MVDM" do
    metric = Measurable::MVDM.new(@data, @labels)
    res = @test.map do |a, b|
      metric.distance(a,b)
    end
    res[0].should > res[2]
    res[0].should > res[3]
    res[1].should > res[2]
    res[1].should > res[3]
  end

  it "should calc MVDM ratio" do
    metric = Measurable::MVDM.new(@data, @labels, :norm => true)
    res = @test.map do |a, b|
      metric.distance(a,b)
    end
    res[0].should > res[2]
    res[0].should > res[3]
    res[1].should > res[2]
    res[1].should > res[3]
  end

  it "should be compatible with object interface" do
    metric = Measurable::MVDM.new(@data, @labels)
    arr1 = [1,1,1]
    arr2 = [2,2,2]
    arr1.measure = metric
    d = arr1.distance(arr2)
    d.should be_within(0.01).of(3.6)
  end

end
