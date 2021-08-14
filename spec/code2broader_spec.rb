$LOAD_PATH << File.join(File.dirname(__FILE__), "..")
require "code2broader.rb"

RSpec.describe CoSFile do
  context "code2broader" do
    it "basic functions" do
      file = CoSFile.new(File.join(File.dirname(__FILE__), "..", "examples/20201016-mxt_syoto01-000010374_3.xlsx"))
      expect(file).not_to be_nil
      expect(file.codes).not_to be_empty
      expect(file.code2broader("8200000133000000")).to eq "8200000130000000"
    end
  end
end