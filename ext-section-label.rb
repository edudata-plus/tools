#!/usr/bin/env ruby

def extract_section_label(str)
  result = {}
  normalized_str = str.tr("　Ａ-Ｚ０-９ｱ-ﾝ", " A-Z0-9ア-ン")
  if /\A(第\d+章|第\d+節|第\d+|\(\d+\)|\(?[ア-ン]\)?)\s+(.+)\z/ =~ normalized_str
    { section: $1, text: $2 }
  else
    { text: normalized_str }
  end
end
