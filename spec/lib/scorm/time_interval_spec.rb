require 'benchmark'
require 'scorm/time_interval'

describe Scorm::TimeInterval do
  describe ".parse" do
    it "defaults to 0 for undefined values" do
      interval = Scorm::TimeInterval.parse("PT0S")
      expect(interval.years).to eq(0)
      expect(interval.months).to eq(0)
      expect(interval.days).to eq(0)
      expect(interval.hours).to eq(0)
      expect(interval.minutes).to eq(0)
      expect(interval.seconds).to eq(0.0)
    end

    it "understands the long example in the SCORM specification" do
      interval = Scorm::TimeInterval.parse("P1Y3M2DT3H")
      expect(interval.years).to eq(1)
      expect(interval.months).to eq(3)
      expect(interval.days).to eq(2)
      expect(interval.hours).to eq(3)
    end

    it "understands the short example" do
      interval = Scorm::TimeInterval.parse("PT3H5M")
      expect(interval.hours).to eq(3)
      expect(interval.minutes).to eq(5)
    end

    it "raises an error when given invalid data" do
      expect { Scorm::TimeInterval.parse("P") }.to  raise_error(Scorm::TimeInterval::InvalidFormat)
      expect { Scorm::TimeInterval.parse("PT") }.to raise_error(Scorm::TimeInterval::InvalidFormat)
    end
  end

  describe ".from_seconds" do
    it "should raise an error when given a negative number" do
      expect { Scorm::TimeInterval.from_seconds(-1) }.to raise_error(Scorm::TimeInterval::InvalidFormat)
    end

    it "should raise an error when given something that can't be turned into a number" do
      expect { Scorm::TimeInterval.from_seconds(Scorm) }.to raise_error(Scorm::TimeInterval::InvalidFormat)
    end

    it "should parse years correctly" do
      {
        0 => 0,
        1000 => 0,
        3600*24*365.25 => 1,
        3600*24*365.25*2 => 2,
        3600*24*365.25*10 => 10
      }.each_pair do |seconds, expected|
        interval = Scorm::TimeInterval.from_seconds(seconds)
        expect(interval.years).to eq(expected), "Expected #{seconds} seconds to equal #{expected} years"
      end
    end

    it "should parse months correctly" do
      {
        0 => 0,
        1000 => 0,
        3600*24*31 => 1,
        3600*24*31*2 => 2,
        3600*24*31*10 => 10
      }.each_pair do |seconds, expected|
        interval = Scorm::TimeInterval.from_seconds(seconds)
        expect(interval.years).to be_zero, "Expected #{seconds} seconds to return zero years"
        expect(interval.months).to eq(expected), "Expected #{seconds} seconds to equal #{expected} months"
      end
    end

    it "should parse days correctly" do
      {
        0 => 0,
        1000 => 0,
        3600*24 => 1,
        3600*24*2 => 2,
        3600*24*10 => 10
      }.each_pair do |seconds, expected|
        interval = Scorm::TimeInterval.from_seconds(seconds)
        expect(interval.years).to be_zero, "Expected #{seconds} seconds to return zero years"
        expect(interval.months).to be_zero, "Expected #{seconds} seconds to return zero months"
        expect(interval.days).to eq(expected), "Expected #{seconds} seconds to equal #{expected} days"
      end
    end

    it "should parse hours correctly" do
      {
        0 => 0,
        1000 => 0,
        3600*23 => 23,
        3600*3 => 3,
        3600*10 => 10
      }.each_pair do |seconds, expected|
        interval = Scorm::TimeInterval.from_seconds(seconds)
        expect(interval.years).to be_zero, "Expected #{seconds} seconds to return zero years"
        expect(interval.months).to be_zero, "Expected #{seconds} seconds to return zero months"
        expect(interval.days).to be_zero, "Expected #{seconds} seconds to return zero days"
        expect(interval.hours).to eq(expected), "Expected #{seconds} seconds to equal #{expected} hours"
      end
    end

    it "should parse minutes correctly" do
      {
        0 => 0,
        1000 => 16,
        60*23 => 23,
        60*3 => 3,
        600 => 10
      }.each_pair do |seconds, expected|
        interval = Scorm::TimeInterval.from_seconds(seconds)
        expect(interval.years).to be_zero, "Expected #{seconds} seconds to return zero years"
        expect(interval.months).to be_zero, "Expected #{seconds} seconds to return zero months"
        expect(interval.days).to be_zero, "Expected #{seconds} seconds to return zero days"
        expect(interval.hours).to be_zero, "Expected #{seconds} seconds to equal zero hours"
        expect(interval.minutes).to eq(expected), "Expected #{seconds} seconds to equal #{expected} minutes"
      end
    end

    it "should parse seconds correctly" do
      {
        0 => 0,
        10 => 10,
        3.1415926 => 3.14,
        3.00 => 3,
        2.8 => 2.8
      }.each_pair do |seconds, expected|
        interval = Scorm::TimeInterval.from_seconds(seconds)
        expect(interval.years).to be_zero, "Expected #{seconds} seconds to return zero years"
        expect(interval.months).to be_zero, "Expected #{seconds} seconds to return zero months"
        expect(interval.days).to be_zero, "Expected #{seconds} seconds to return zero days"
        expect(interval.hours).to be_zero, "Expected #{seconds} seconds to equal zero hours"
        expect(interval.minutes).to be_zero, "Expected #{seconds} seconds to equal zero minutes"
        expect(interval.seconds).to eq(expected)
      end
    end
  end

  describe "#seconds" do
    it "should discard decimals if they are not needed" do
      i = Scorm::TimeInterval.new
      i.seconds = 3.00
      expect(i.seconds).to eq(3)
    end

    it "should be limited to two decimals" do
      i = Scorm::TimeInterval.new
      i.seconds = 3.1415
      expect(i.seconds).to eq(3.14)
    end
  end

  describe "#to_s" do
    it "returns a blank interval when given nothing" do
      expect(Scorm::TimeInterval.new.to_s).to eq("PT0S")
    end

    it "should result in the same string given to .parse" do
      expect(Scorm::TimeInterval.parse("PT3H5M").to_s).to eq("PT3H5M")
    end

    it "should strip out zeroes" do
      expect(Scorm::TimeInterval.parse("PT003H05M5.00S").to_s).to eq("PT3H5M5S")
    end
  end

  describe "#to_f" do
    it "returns 0 when given nothing" do
      expect(Scorm::TimeInterval.new.to_f).to eq(0)
    end

    it "returns the same number as given to .from_seconds" do
      [1, 3.14, 10, 1000, 3600*24*235].each do |seconds|
        interval = Scorm::TimeInterval.from_seconds(seconds)
        if interval.to_f != seconds
          puts interval.to_s
        end
        expect(interval.to_f).to eq(seconds), "Expected #{seconds} seconds, got #{interval.to_f}"
      end
    end
  end
end
