require 'nokogiri'

class Lexer

  def initialize(file)
    @doc = Nokogiri::HTML open(file).read
    @doc.encoding = 'utf-8'
    @doc = @doc.xpath("//text").text
    @pos = 0
  end 

  def nextChar(*n)
    if n.length > 0
      @pos += n[0]
    else
      @pos += 1
    end
  end

  def scanChar(*n)
    if n.length > 0
      @doc[@pos+n[0]]
    else 
      @doc[@pos+1]
    end
  end


  def delimiter_reached?(delimiters)
    delimiters.length.times do |i|
      if scanChar(i) != delimiters[i]
        return false
      end
    end 
    true
  end

  def read_until(*delimiters)
    start = @pos
    while not delimiter_reached?(delimiters) 
      nextChar
    end

    str = [@doc[start..@pos-1]]

    delimiters.length.times do |i|
      nextChar
    end
    str
  end 

  def anywhere_token(text)
    tokens = Array.new
    text
  end

  def next_line_token
    if @pos == @doc.length
      "EOF"
    elsif scanChar(0) == "\n"
      nextChar
      [:p, "\n"]
    elsif delimiter_reached? ["{", "|"]
      nextChar 2
      [:table, read_until("|", "}")]
    elsif delimiter_reached? ["{", "{"]
      nextChar 2
      text = read_until("}", "}")
      # parse text with anywhere rules
      [:category, text]
    elsif delimiter_reached?(["=", "="])
      # determine heading level

      h = 0

      until scanChar(h) != "="
        h += 1
      end

      nextChar h
      text = read_until(*("=" * h).split("")) # * is the splat operator
      # parse text with anywhere rules
      [:heading, text]
    elsif scanChar(0) == "#" and scanChar(1).downcase == "r"
      [:redirect, get_to_end_of_line]
    elsif ["*", "#", ":", ";"].include? scanChar(0)
      # list
      list = Array.new
      while ["*", "#", ":", ";"].include? scanChar(0)
        text = get_to_end_of_line
        # parse text with anywhere rules
        list.push text
        nextChar
      end
      [:list, list]
    elsif delimiter_reached?(["-", "-", "-", "-"])
      [:hr, get_to_end_of_line] 
    else
      text = get_to_end_of_line
      # parse text with anywhere rules
      [:text, anywhere_token(text)]
      #[:text, text]
    end
  end

  def get_to_end_of_line
    start = @pos
    while @doc[@pos] != "\n" and @pos != @doc.length
      nextChar
    end
    [@doc[start..@pos-1]] # @pos - 1 to ignore the newline
  end

  def scan
    first_scan_tokens = Array.new
    tokens = Array.new
    while (token = next_line_token) != "EOF"
      first_scan_tokens.push token
    end

puts "#{first_scan_tokens}"
    first_scan_tokens.each do |token|
      # scan every token for anywhere symbols
      
    end
  end

end

lexer = Lexer.new(ARGV[0])
lexer.scan
