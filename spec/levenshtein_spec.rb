describe Measurable::Levenshtein do
  it "can be extended seperately" do
    klass = Class.new do
      extend Measurable::Levenshtein
    end

    expect(klass.levenshtein("ab", "abc")).to eq 1
  end

  it "can be included seperately" do
    klass = Class.new do
      include Measurable::Levenshtein
    end

    expect(klass.new.levenshtein("ab", "abc")).to eq 1
  end

  context "strings" do
    it "handles empty" do
      expect(Measurable.levenshtein("", "")).to eq 0
      expect(Measurable.levenshtein("", "abcd")).to eq 4
      expect(Measurable.levenshtein("abcd", "")).to eq 4
    end

    it "should not count equality" do
      expect(Measurable.levenshtein("aa", "aa")).to eq 0
    end

    it "should count deletion" do
      expect(Measurable.levenshtein("ab", "a")).to eq 1
    end

    it "should count insertion" do
      expect(Measurable.levenshtein("ab", "abc")).to eq 1
    end

    it "should count substitution" do
      expect(Measurable.levenshtein("aa", "ab")).to eq 1
    end
  end

  context "arrays" do
    it "handles empty" do
      expect(Measurable.levenshtein([], [])).to eq 0
      expect(Measurable.levenshtein([], %w[ a b c d ])).to eq 4
      expect(Measurable.levenshtein(%w[ a b c d ], [])).to eq 4
    end

    it "should not count equality" do
      expect(Measurable.levenshtein(%w[ a ], %w[ a ])).to eq 0
    end

    it "should count deletion" do
      expect(Measurable.levenshtein(%w[ a b ], %w[ a ])).to eq 1
    end

    it "should count insertion" do
      expect(Measurable.levenshtein(%w[ a b ], %w[ a b c ])).to eq 1
    end

    it "should count substitution" do
      expect(Measurable.levenshtein(%w[ a a ], %w[ a b ])).to eq 1
    end
  end
end
