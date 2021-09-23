$LOAD_PATH << File.join(File.dirname(__FILE__), "..")
require "ext-section-label.rb"

RSpec.describe "extract_section_label" do
  example_file = File.join(File.dirname(__FILE__), "..", "examples","20210820-mxt_syoto01-000010374_01.xlsx")
  it "should work basic functions" do
    result = extract_section_label("第２章　各教科")
    expect(result[:section]).to eq "第2章"
    expect(result[:text]).to eq "各教科"

    result = extract_section_label("第１節　国　　　語")
    expect(result[:section]).to eq "第1節"
    expect(result[:text]).to eq "国   語"

    result = extract_section_label("１　教育課程の改善と学校評価等")
    expect(result[:section]).to eq "1"
    expect(result[:text]).to eq "教育課程の改善と学校評価等"

    result = extract_section_label("(1) 日常生活に必要な国語について，その特質を理解し適切に使うことができるようにする。")
    expect(result[:section]).to eq "(1)"
    expect(result[:text]).to eq "日常生活に必要な国語について，その特質を理解し適切に使うことができるようにする。"

    result = extract_section_label("２　教科等横断的な視点に立った資質・能力の育成")
    expect(result[:section]).to eq "2"
    expect(result[:text]).to eq "教科等横断的な視点に立った資質・能力の育成"

    result = extract_section_label("２　教科等横断的な視点に立った資質・能力の育成")
    expect(result[:section]).to eq "2"
    expect(result[:text]).to eq "教科等横断的な視点に立った資質・能力の育成"

    result = extract_section_label("(ｳ) 給食，休憩などの時間については，各学校において工夫を加え，適切に定めること。")
    expect(result[:section]).to eq "(ウ)"
    expect(result[:text]).to eq "給食，休憩などの時間については，各学校において工夫を加え，適切に定めること。"

    result = extract_section_label("Ｂ　書くこと")
    expect(result[:section]).to eq "B"
    expect(result[:text]).to eq "書くこと"

    result = extract_section_label("１　主体的・対話的で深い学びの実現に向けた授業改善\n　各教科等の指導に当たっては，次の事項に配慮するものとする。")
    expect(result[:section]).to eq "1"
    expect(result[:text]).to eq "主体的・対話的で深い学びの実現に向けた授業改善\n 各教科等の指導に当たっては，次の事項に配慮するものとする。"

    result = extract_section_label("③　物の溶け方，振り子の運動，電流がつくる磁力について追究する中で，主体的に問題解決しようとする態度を養う。")
    expect(result[:section]).to eq "③"
    expect(result[:text]).to eq "物の溶け方，振り子の運動，電流がつくる磁力について追究する中で，主体的に問題解決しようとする態度を養う。"

    result = extract_section_label("a 　単文")
    expect(result[:section]).to eq "a"
    expect(result[:text]).to eq "単文"

  end
end
