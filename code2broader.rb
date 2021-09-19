#!/usr/bin/env ruby

require "roo"

class CoSFile
  attr_reader :codes
  def initialize(file, sheet = nil)
    @codes = {}
    xlsx = Roo::Excelx.new(file, {headers: true})
    xlsx.default_sheet = sheet if sheet
    idx = nil
    xlsx.each_row_streaming(pad_cells: true) do |row|
      if idx.nil?
        row.each_with_index do |r, i|
          idx = i if r and r.value == "学習指導要領コード"
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
      @codes[row[idx].value] = true
    end
    #p @codes.keys[0..10]
    #p @codes.keys.size
  end
  def code2broader(code)
    #p code
    code_numbers = code.scan(/./)
    #p code_numbers
    idx = code_numbers.reverse.find_index{|i| i != "0" }
    #p [idx: idx]
    return nil if idx.nil?
    if idx == 13 or ( idx == 10 and code_numbers[3] == "0" and code_numbers[4] == "0" )
      new_codes = code_numbers.dup
      new_codes[2] = "n"
      new_code = new_codes.join
      if @codes[new_code]
        return new_code
      end
    end
    if idx == 10 and code_numbers[4] == "1"
      new_codes = code_numbers.dup
      new_codes[4] = "0"
      new_code = new_codes.join
      if @codes[new_code]
        return new_code
      end
    end
    if code_numbers[5] != "0"
      new_codes = code_numbers.dup
      new_codes[5] = "0"
      new_code = new_codes.join
      if @codes[new_code]
        return new_code
      end
    end
    if code_numbers[2] == "1" and code_numbers[4] == "0" and idx <= 6 #国語 別表 学年別漢字配当表
      new_codes = code_numbers.dup
      new_codes[9] = "0"
      new_codes[10] = "0"
      new_codes[11] = "0"
      new_code = new_codes.join
      if @codes[new_code]
        return new_code
      end
    end
    code_numbers[16-idx-1] = "0"
    new_code = code_numbers.join
    #p [new_code: new_code]
    if @codes[new_code]
      new_code
    else
      code2broader(new_code)
    end
  end
end

if $0 == __FILE__
  cos = CoSFile.new(ARGV[0], "all_数字はAに")
  if ARGV[1]
    p cos.code2broader(ARGV[1])
  else
    cos.codes.keys.sort.each do |c|
      puts [c, cos.code2broader(c)].join("\t")
    end
  end
end
