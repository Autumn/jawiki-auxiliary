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
      start_of_line
    elsif @doc[@pos] == "\n"
      nextChar
      start_of_line
    elsif @pos == @doc.length 
      "EOF"
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
