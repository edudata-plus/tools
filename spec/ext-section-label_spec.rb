$LOAD_PATH << File.join(File.dirname(__FILE__), "..")
require "ext-section-label.rb"

RSpec.describe "extract_section_label" do
  example_file = File.join(File.dirname(__FILE__), "..", "examples","20210820-mxt_syoto01-000010374_01.xlsx")
  it "should work basic functions" do
    [
      [
        "第２章　各教科",
        "第2章", "各教科"
      ],
      [
        "第１節　国　　　語",
        "第1節", "国   語"
      ],
      [
        "(1) 日常生活に必要な国語について，その特質を理解し適切に使うことができるようにする。",
        "(1)", "日常生活に必要な国語について，その特質を理解し適切に使うことができるようにする。"
      ],
    ].each do |input, section, text|
      result = extract_section_label(input)
      expect(result[:section]).to eq section
      expect(result[:text]).to eq text
    end
  end
end
