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

  def get_start_of_line_token
    if @doc[@pos] == "\n"
      nextChar
      [:p]
    elsif @doc[@pos] == "{" 
      if scanChar == "|"
        nextChar 2
        [:table, read_until("|", "}")]
      elsif scanChar == "{"
        nextChar 2
        [:category, read_until("}", "}")]
      end
    elsif @doc[@pos] == "="
      if scanChar == "=" # heading 
        # determine heading level

        h = 0

        until scanChar(h) != "="
          h += 1
        end

        nextChar h
        
        [:heading, read_until(*("=" * h).split(""))]
      end
    elsif ["*", "#", ":", ";"].include? scanChar(0)
      # list
      list = Array.new
      while ["*", "#", ":", ";"].include? scanChar(0)
        list.push get_to_end_of_line
        nextChar
      end
      [:list, list]
    else
      [:text, get_to_end_of_line]
    end
  end

  def get_to_end_of_line
    start = @pos
    while @doc[@pos] != "\n" and @pos != @doc.length
      nextChar
    end
    [@doc[start..@pos]]
  end

  def start_of_line
    # blank - new paragraph
    # list - care required
    # table - scan to end of table and return entire blob
    # text - read until end of line, then parse token separately for links/formatting/other things
    # horizontal rule - remove
    # redirect - use
    start = @pos
  
    while @doc[@pos] != "\n" and @pos != @doc.length
      nextChar
    end
    [@doc[start..@pos]]
  end

  def next_token
    if @pos == 0
      get_start_of_line_token
    elsif @doc[@pos] == "\n"
      nextChar
      get_start_of_line_token
    elsif @pos == @doc.length 
      "EOF"
    else
      [:text, get_to_end_of_line]
    end
  end 

  def scan
    tokens = Array.new
    while (token = next_token) != "EOF"
      tokens.push token
    end
    puts "#{tokens}"
  end

end

lexer = Lexer.new(ARGV[0])
lexer.scan
