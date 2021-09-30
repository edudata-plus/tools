$LOAD_PATH << File.join(File.dirname(__FILE__), "..")
require "cosfile.rb"

RSpec.describe CoSFile do
  include CoSFile
  context "parse_xlsx" do
    example_file = File.join(File.dirname(__FILE__), "..", "examples","20201016-mxt_syoto01-000010374_4.xlsx")
    it "should work basic functions" do
      parse_xlsx(example_file) do |code, text|
        expect(code).not_to be_nil
      end
    end
    it "should treat italic expressions" do
      parse_xlsx(example_file) do |code, text|
        if code == "8350232100000000"
          expect(text).to start_with "(1) 数の平方根，多項式と"
        end
      end
    end
  end
end
