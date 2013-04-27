require 'nokogiri'

class Parser
  def initialize(text)
    @pos = 0
    @text = text
  end

  def nextChar(*n)
    if n.length == 0
      @pos += 1
    else
      @pos += n[0]
    end
  end 

  def printChar
    print @text[@pos]
  end

  def parseLink
    print "[\"link\", \""
    
    while checkDelimiter("]", "]") == false
      if checkDelimiter("[", "[")
        nextChar 2
        print "\", "
        parseLink
        print ", \""
      end
      print @text[@pos]
      nextChar
    end
    print "\"]"
    nextChar(2)
  end

  def parseLink
    tokens = Array.new
    start = @pos
    while checkDelimiter("]", "]") == false
      if checkDelimiter("[", "[")
        tokens.push [:link, @text[start..@pos-1]]
        nextChar 2
        tokens.push parseLink
        start = @pos
      end
      nextChar
    end
    tokens.push [:link, @text[start..@pos-1]]
    nextChar 2
    tokens
  end

  def parseTemplate
#    print "["
    while varDelimiter("}", "}") == false
      if varDelimiter("{", "{") #checkDelimiter("{", "{")
        nextChar(2)
        parseTemplate
      end
#      print @text[@pos]
      nextChar
    end
#    print "]"
    nextChar(2)
  end

  def checkDelimiter(first, second)
    if @text[@pos] == first and @text[@pos+1] == second
      return true
    end
    false
  end

  def startTemplate
    varDelimiter("{", "{")
  end

  def startLink
    varDelimiter("[", "[")
  end

  def varDelimiter(*delims)
    delims.length.times do |i|
      if delims[i] != @text[@pos+i]
        return false
      end
    end
    true
  end

  def checkFormatting
    if varDelimiter("\'", "\'", "\'", "\'", "\'")
      return "bold+italic"
    elsif varDelimiter("\'", "\'", "\'")
      return "bold"
    elsif varDelimiter("\'", "\'")
      return "italic"
    end
    return ""
  end

  def skipFormatting 
    if varDelimiter("\'", "\'", "\'", "\'", "\'")
      nextChar(5)
    elsif varDelimiter("\'", "\'", "\'")
      nextChar(5)
    elsif varDelimiter("\'", "\'")
      nextChar(5)
    end
  end

  def parse
    while @pos < @text.length
      if startLink
        nextChar(2)
        puts "#{parseLink}"
      elsif startTemplate
        nextChar(2)
        parseTemplate
      elsif varDelimiter("{", "|") 
        nextChar(2)
        while not varDelimiter("|", "}")
          nextChar
        end
        nextChar(2)
      elsif @text[@pos] == "\n"
        printChar
        nextChar(1)
        # check heading
        if varDelimiter("=", "=")
          nextChar(2)
          print "[\"h2\", \""
          while not varDelimiter("=", "=")
            print @text[@pos]
            nextChar
          end
          nextChar(2)
          print "\"]"
        # check bullet lists
        elsif varDelimiter("*")
          nextChar
        end
      else
        ### change - formatting can occur /anywhere/ 
        if @text[@pos] == "\'"
          #if checkFormatting != ""
          #   skipFormatting 
          #end
          nextChar
        else
          
          print @text[@pos]
          nextChar
        end
      end
    end
  end

end

file = open("2")
article = Nokogiri::HTML file.read
article.encoding = 'utf-8'
text = article.xpath("//text").text


parser = Parser.new(text)

parser.parse
