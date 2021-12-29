#!/usr/bin/env ruby

require "roo"

module CoSFile
  def parse_xlsx(file, sheet = nil)
    xlsx = Roo::Excelx.new(file, {headers: true})
    xlsx.default_sheet = sheet if sheet
    idx = nil
    idx_text = nil
    xlsx.each_row_streaming(pad_cells: true) do |row|
      if idx.nil?
        row.each_with_index do |r, i|
          idx = i if r and r.value == "学習指導要領コード"
          idx_text = i if r and r.value == "学習指導要領テキスト"
        end
        next
      end
      #p row
      #p row[7]
      #p row["教育要領コード"]
      next if row[idx].value.nil?
      if row[idx].value.size != 16
        STDERR.puts "skip not 16 digit: [#{row[idx].value.to_s.dump}]"
        next
      end
      text = row[idx_text].value
      if text.start_with? "<html>"
        text.sub!(/\A<html>/, "")
        text.sub!(/<\/html>\z/, "")
      end
      yield(row[idx].value, text)
    end
  end
end
