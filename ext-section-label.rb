#!/usr/bin/env ruby

require "csv"
require "roo"

require_relative "cosfile.rb"
require_relative "code2broader.rb"

def extract_section_label(str)
  result = {}
  normalized_str = str.tr("　Ａ-Ｚａ-ｚ０-９ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄ（）", " A-Za-z0-9アイウエオカキクケコサシスセソタチツテト()").strip
  if /\A(第\d+章|第\d+款|第\d+節|第\d+|\(\d+\)|\([a-z]+\)|\d+|\(?[ア-ン]\)?|[A-Za-z]+|[①-⑳]|[㋐-㋻])\s*(.+)\z/m =~ normalized_str
    { section: $1, text: $2.strip }
  else
    { text: normalized_str.strip }
  end
end

def shorten(str, length = 120)
  str = str.split(/\r?\n/o).first
  if str.length > length
    str[0..length] + "..."
  else
    str
  end
end

if $0 == __FILE__
  include CoSFile
  options = {}
  done = {}
  result = ""
  if ARGV.first and ARGV.first == "-csv"
    options[:csv] = true
    ARGV.shift
  end
  data = Code2Broader.new(ARGV[0], ARGV[1])
  if options[:csv]
    result << "\xEF\xBB\xBF" #UTF-8 BOM
  else
    result << "@prefix cs: <https://w3id.org/jp-cos/>.\n"
    result << "@prefix schema: <http://schema.org/>.\n"
  end
  data.each do |code|
    label = data.labels[code]
    parent_labels = [ data.labels[code] ]
    parent = code
    while (parent = data.code2broader(parent)) do
      if data.labels[parent]
        parent_labels << data.labels[parent]
      end
    end
    parent_labels = parent_labels.map do |e|
      e[:section] || shorten(e[:text], 20)
    end.reverse
    if options[:csv]
      csv_str = CSV.generate(row_sep: "\r\n") do |csv|
        csv << [ code, #row[idx_text],
                 label[:section], label[:text].gsub(/\n/, "\r\n"),
                 parent_labels.join(" / ")
               ]
      end
      result << csv_str
    else
      result << "cs:#{code} "
      triples = []
      triples << "cs:sectionNumber \"#{label[:section]}\"" if label[:section]
      triples << "cs:sectionText '''#{label[:text]}'''"
      triples << "cs:sectionNumberHierarchy \"#{parent_labels.join(" / ")}\""
      result << triples.join(";\n  ")
      result << ".\n"
      parent_code = data.code2broader(code)
      result << "cs:#{parent_code} schema:hasPart cs:#{code}.\n" if parent_code
    end
  end
  puts result
end
