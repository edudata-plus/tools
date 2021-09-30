$LOAD_PATH << File.join(File.dirname(__FILE__), "..")
require "code2broader.rb"

RSpec.describe Code2Broder do
  context "code2broader" do
    example_file = {
      v82: File.join(File.dirname(__FILE__), "..", "examples","20210820-mxt_syoto01-000010374_01.xlsx"),
      v83: File.join(File.dirname(__FILE__), "..", "examples","20201016-mxt_syoto01-000010374_4.xlsx"),
      v86: File.join(File.dirname(__FILE__), "..", "examples","000090504.xlsx"),
      v72: File.join(File.dirname(__FILE__), "..", "examples","000083948.xlsx"),
    }
    it "should work basic functions" do
      file = Code2Broder.new(example_file[:v82])
      expect(file).not_to be_nil
      expect(file.codes).not_to be_empty
      expect(file.code2broader("8200000133000000")).to eq "8200000130000000"
    end
    it "should treat 5th digit as zero for a subject" do
      file = Code2Broder.new(example_file[:v82])
      expect(file.code2broader("82201L0000000000")).to eq "82200L0000000000"
    end
    it "should treat 3rd digit as 'n' for a common category for subjects" do
      file = Code2Broder.new(example_file[:v82])
      expect(file.code2broader("8210000000000000")).to eq "82n0000000000000"
      expect(file.code2broader("82200L0000000000")).to eq "82n0000000000000"
      expect(file.code2broader("82n0000000000000")).to eq "8200000000000000"
    end
    it "should treat 6th digit as zero for all the grades" do
      file = Code2Broder.new(example_file[:v82])
      expect(file.code2broader("82000A0621000000")).to eq "8200000620000000"
      expect(file.code2broader("82000C0622000000")).to eq "8200000620000000"
      expect(file.code2broader("82103A0170000000")).to eq "8210300100000000"
      expect(file.code2broader("8210330213000000")).to eq "8210300210000000"
      expect(file.code2broader("82103L0216300000")).to eq "8210300216000000"
      expect(file.code2broader("82103A0216400000")).to eq "8210300216000000"
      expect(file.code2broader("8210010110000000")).to eq "8210000100000000"
    end
    it "should treat a list of Kanji characters" do
      file = Code2Broder.new(example_file[:v82])
      expect(file.code2broader("8210020120010000")).to eq "8210020120000000"
      expect(file.code2broader("8210020120020000")).to eq "8210020120000000"
      expect(file.code2broader("8210020120100000")).to eq "8210020120000000"
      expect(file.code2broader("8210020120110000")).to eq "8210020120000000"
      expect(file.code2broader("8210020120200000")).to eq "8210020120000000"
      expect(file.code2broader("8210020120210000")).to eq "8210020120000000"
    end
    it "should treat a list of historical figures" do
      file = Code2Broder.new(example_file[:v82])
      expect(file.code2broader("8220265230100000")).to eq "8220265230000000"
      expect(file.code2broader("8220265230200000")).to eq "8220265230000000"
      expect(file.code2broader("8220265231000000")).to eq "8220265230000000"
      expect(file.code2broader("8220265231100000")).to eq "8220265230000000"
      file = Code2Broder.new(example_file[:v72])
      expect(file.code2broader("7220265140100000")).to eq "7220265140000000"
      expect(file.code2broader("7220265140200000")).to eq "7220265140000000"
      expect(file.code2broader("7220265141100000")).to eq "7220265140000000"
      expect(file.code2broader("7220265142100000")).to eq "7220265140000000"
    end
    it "should tread a list of musical notes" do
      file = Code2Broder.new(example_file[:v82])
      expect(file.code2broader("8280300290000000")).to eq "8280300200000000"
      expect(file.code2broader("8280300290100000")).to eq "8280300290000000"
      expect(file.code2broader("8280300290200000")).to eq "8280300290000000"
      expect(file.code2broader("8280300291000000")).to eq "8280300290000000"
      expect(file.code2broader("8280300291100000")).to eq "8280300290000000"
      file = Code2Broder.new(example_file[:v83])
      expect(file.code2broader("83803002A0100000")).to eq "83803002A0000000"
      expect(file.code2broader("83803002A0200000")).to eq "83803002A0000000"
      expect(file.code2broader("83803002A0300000")).to eq "83803002A0000000"
      expect(file.code2broader("83803002A1000000")).to eq "83803002A0000000"
      expect(file.code2broader("83803002A1100000")).to eq "83803002A0000000"
      file = Code2Broder.new(example_file[:v72])
      expect(file.code2broader("7280300260100000")).to eq "7280300260000000"
      expect(file.code2broader("7280300260200000")).to eq "7280300260000000"
      expect(file.code2broader("7280300261000000")).to eq "7280300260000000"
      expect(file.code2broader("7280300261100000")).to eq "7280300260000000"
    end
    it "should treat 2nd digit for several types of disabilities" do
      file = Code2Broder.new(example_file[:v86])
      expect(file.code2broader("8700000331400000")).to eq "8600000331000000"
      expect(file.code2broader("8900000331500000")).to eq "8600000331000000"
    end
  end
end
