#!/usr/bin/env ruby

require "csv"
require "roo"

def extract_section_label(str)
  result = {}
  normalized_str = str.tr("　Ａ-Ｚ０-９ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄ", " A-Z0-9アイウエオカキクケコサシスセソタチツテト")
  if /\A(第\d+章|第\d+節|第\d+|\(\d+\)|\d+|\(?[ア-ン]\)?|[A-Za-z]+|[①-⑳])\s+(.+)\z/m =~ normalized_str
    { section: $1, text: $2 }
  else
    { text: normalized_str }
  end
end

if $0 == __FILE__
  xlsx = Roo::Excelx.new(ARGV[0], {headers: true})
  #xlsx.default_sheet = "all_数字はAに"
  idx = nil
  idx_text = nil
  print "\xEF\xBB\xBF" #UTF-8 BOM
  csv_str = CSV.generate(row_sep: "\r\n") do |csv|
    xlsx.each_row_streaming(pad_cells: true) do |row|
      if idx.nil?
        row.each_with_index do |r, i|
          idx = i if r and r.value == "学習指導要領コード"
          idx_text = i if r and r.value == "学習指導要領テキスト"
        end
        next
      end
      next if row[idx].value.nil?
      result = extract_section_label(row[idx_text].value)
      csv << [ row[idx], #row[idx_text],
               result[:section], result[:text].gsub(/\n/, "\r\n") ]
    end
  end
  print csv_str
end
