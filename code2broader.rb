#!/usr/bin/env ruby

require_relative "cosfile.rb"

class Code2Broader
  include CoSFile
  attr_reader :codes, :labels
  def initialize(file, sheet = nil)
    @codes = {}
    @labels = {}
    parse_xlsx(file, sheet) do |code, text|
      @codes[code] = true
      @labels[code] = extract_section_label(text)
    end
    #p @codes.keys[0..10]
    STDERR.puts "#{@codes.keys.size} codes loaded..."
  end
  def each
    @codes.keys.sort.each do |code|
      yield code
    end
  end
  include Enumerable

  def code2broader(code, original = nil)
    #p code
    code_numbers = code.scan(/./)
    #p code_numbers
    idx = code_numbers.reverse.find_index{|i| i != "0" }
    #p [code, idx]
    #p original
    return nil if idx.nil?
    if %q[4 B C D E F G H].include? code_numbers[1] and (("P".."Z").cover? code_numbers[2] or ("a".."k").cover? code_numbers[2])
      new_codes = code_numbers.dup
      new_codes[2] = "o"
      new_code = new_codes.join
      if @codes[new_code]
        return new_code
      end
    end
    if idx == 13 or ( idx == 10 and code_numbers[3] == "0" and code_numbers[4] == "0" )
      if original and %q[3 4 5 6].include? original[5]
        new_codes = code_numbers.dup
        new_codes[5] = "L"
        new_code = new_codes.join
        if @codes[new_code]
          return new_code
        end
      end
      if code_numbers[2] != "n"
        new_codes = code_numbers.dup
        new_codes[2] = "n"
        new_code = new_codes.join
        if @codes[new_code]
          return new_code
        end
      end
    end
    if idx == 10 and code_numbers[4] != "0"
      new_codes = code_numbers.dup
      new_codes[4] = "0"
      new_code = new_codes.join
      if @codes[new_code]
        return new_code
      end
    end
    if code_numbers[3] != "0"
      new_codes = code_numbers.dup
      new_codes[3] = "0"
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
    if idx <= 6 and
        ( code.start_with? "822026523" or       #社会科 人物リスト
          code.start_with? "722026514" or
          code.start_with? "828030029" or       #音楽 音符記号等
          code.start_with? "83803002A" or
          code.start_with? "728030026" )
      new_codes = code_numbers.dup
      new_codes[9] = "0"
      new_codes[10] = "0"
      new_code = new_codes.join
      if @codes[new_code]
        return new_code
      end
    end
    if %q[7 8 9 A].include? code_numbers[1]
      new_codes = code_numbers.dup
      new_codes[16-idx-1] = "0"
      new_code = new_codes.join
      return new_code if @codes[new_code]
      new_codes[1] = "6"
      new_code = new_codes.join
      return new_code if @codes[new_code]
    end
    if %q[D E F H].include? code_numbers[1]
      new_codes = code_numbers.dup
      new_codes[16-idx-1] = "0"
      new_code = new_codes.join
      p new_code
      return new_code if @codes[new_code]
      new_codes[1] = "C"
      new_code = new_codes.join
      p [new_code, @codes[new_code]]
      return new_code if @codes[new_code]
    end
    if %q[C D E F G H].include? code_numbers[1]
      new_codes = code_numbers.dup
      new_codes[16-idx-1] = "0"
      new_code = new_codes.join
      return new_code if @codes[new_code]
      new_codes[1] = "B"
      new_code = new_codes.join
      return new_code if @codes[new_code]
    end
    code_numbers[16-idx-1] = "0"
    new_code = code_numbers.join
    #p [new_code: new_code]
    if @codes[new_code]
      new_code
    else
      code2broader(new_code, original || code)
    end
  end

  def extract_section_label(str)
    result = {}
    normalized_str = str.strip.tr("　Ａ-Ｚａ-ｚ０-９ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄ（）", " A-Za-z0-9アイウエオカキクケコサシスセソタチツテト()")
    if /\A(第\d+章|第\d+款|第\d+節|第\d+|\(\d+\)|\([a-z]+\)|\d+|\(?[ア-ン]\)?|[A-Za-z]+|[①-⑳]|[㋐-㋻])\s*(.+)\z/m =~ normalized_str
      { section: $1, text: $2.strip }
    else
      { text: normalized_str.strip }
    end
  end
end

if $0 == __FILE__
  opt_tsv = false
  if ARGV[0] == "-tsv"
    opt_tsv = true
    ARGV.shift
  end
  cos = Code2Broader.new(ARGV[0], "all_数字はAに")
  if opt_tsv
    if ARGV[1]
      p cos.code2broader(ARGV[1])
    else
      cos.codes.keys.sort.each do |c|
        puts [c, cos.code2broader(c)].join("\t")
      end
    end
  else
    puts "@prefix cs: <https://w3id.org/jp-cos/>."
    puts "@prefix schema: <http://schema.org/>."
    cos.codes.keys.sort.each do |c|
      parent = cos.code2broader(c)
      puts "cs:#{parent} schema:hasPart cs:#{c}." if parent
    end
  end
end
