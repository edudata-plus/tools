$LOAD_PATH << File.join(File.dirname(__FILE__), "..")
require "code2broader.rb"

RSpec.describe CoSFile do
  context "code2broader" do
    example_file = File.join(File.dirname(__FILE__), "..", "examples/20201016-mxt_syoto01-000010374_3.xlsx")
    it "basic functions" do
      file = CoSFile.new(example_file)
      expect(file).not_to be_nil
      expect(file.codes).not_to be_empty
      expect(file.code2broader("8200000133000000")).to eq "8200000130000000"
    end
    it "5th digit should be zero for a subject" do
      file = CoSFile.new(example_file)
      expect(file.code2broader("82201L0000000000")).to eq "82200L0000000000"
    end
    it "3rd digit should be 'n' for a common category for subjects" do
      file = CoSFile.new(example_file)
      expect(file.code2broader("8210000000000000")).to eq "82n0000000000000"
      expect(file.code2broader("82200L0000000000")).to eq "82n0000000000000"
    end
  end
end
