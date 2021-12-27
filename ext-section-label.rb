#!/usr/bin/env ruby

require "csv"
require "roo"

require_relative "cosfile.rb"

def extract_section_label(str)
  result = {}
  normalized_str = str.strip.tr("　Ａ-Ｚａ-ｚ０-９ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄ（）", " A-Za-z0-9アイウエオカキクケコサシスセソタチツテト()")
  if /\A(第\d+章|第\d+款|第\d+節|第\d+|\(\d+\)|\([a-z]+\)|\d+|\(?[ア-ン]\)?|[A-Za-z]+|[①-⑳]|[㋐-㋻])\s*(.+)\z/m =~ normalized_str
    { section: $1, text: $2.strip }
  else
    { text: normalized_str.strip }
  end
end

if $0 == __FILE__
  include CoSFile
  done = {}
  if ARGV.first == "-csv"
    ARGV.shift
    print "\xEF\xBB\xBF" #UTF-8 BOM
    csv_str = CSV.generate(row_sep: "\r\n") do |csv|
      parse_xlsx(ARGV[0], ARGV[1]) do |code, text|
        next if done[code]
        result = extract_section_label(text)
        csv << [ code, #row[idx_text],
                 result[:section], result[:text].gsub(/\n/, "\r\n") ]
        done[code] = true
      end
    end
    print csv_str
  else
    puts "@prefix cs: <https://w3id.org/jp-cos/>."
    parse_xlsx(ARGV[0], ARGV[1]) do |code, text|
      next if done[code]
      label = extract_section_label(text)
      print "cs:#{code} "
      result = []
      result << "cs:sectionNumber \"#{label[:section]}\"" if label[:section]
      result << "cs:sectionText '''#{label[:text]}'''"
      print result.join(";\n  ")
      puts "."
      done[code] = true
    end
  end
end
