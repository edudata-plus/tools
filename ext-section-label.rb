#!/usr/bin/env ruby

require "csv"
require "roo"

def extract_section_label(str)
  result = {}
  normalized_str = str.strip.tr("　Ａ-Ｚａ-ｚ０-９ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄ（）", " A-Za-z0-9アイウエオカキクケコサシスセソタチツテト()")
  if /\A(第\d+章|第\d+款|第\d+節|第\d+|\(\d+\)|\([a-z]+\)|\d+|\(?[ア-ン]\)?|[A-Za-z]+|[①-⑳]|[㋐-㋻])\s*(.+)\z/m =~ normalized_str
    { section: $1, text: $2 }
  else
    { text: normalized_str }
  end
end

if $0 == __FILE__
  print "\xEF\xBB\xBF" #UTF-8 BOM
  include CoSFile
  csv_str = CSV.generate(row_sep: "\r\n") do |csv|
    parse_xlsx(ARGV[0], ARGV[1]) do |code, text|
      result = extract_section_label(text)
      csv << [ code, #row[idx_text],
               result[:section], result[:text].gsub(/\n/, "\r\n") ]
    end
  end
  print csv_str
end
