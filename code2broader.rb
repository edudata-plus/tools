#!/usr/bin/env rubyt

require "roo"

@codes = {}
xlsx = Roo::Excelx.new(ARGV[0], {headers: true})
xlsx.default_sheet = "all_数字はAに"
xlsx.each_row_streaming(pad_cells: true, headers: true, offset: 4) do |row|
  #p row
  #p row[7]
  # p row["教育要領コード"]
  next if row[7].value.nil?
  if row[7].value.size != 16
    STDERR.puts "skip not 16 digit: [#{row[7].value.to_s.dump}]"
    next
  end
  @codes[row[7].value] = true
end
#p @codes.keys[0..10]
#p @codes.keys.size

def code2broader(code)
  #p code
  code_numbers = code.scan(/./)
  #p code_numbers
  idx = code_numbers.reverse.find_index{|i| i != "0" }
  #p [idx: idx]
  return nil if idx.nil?
  code_numbers[16-idx-1] = "0"
  new_code = code_numbers.join
  #p [new_code: new_code]
  if @codes[new_code]
    new_code
  else
    code2broader(new_code)
  end
end

if ARGV[1]
  p code2broader(ARGV[1])
else
  @codes.keys.sort.each do |c|
    puts [c, code2broader(c)].join("\t")
  end
end
