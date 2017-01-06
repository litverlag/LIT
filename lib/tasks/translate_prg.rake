##
# This is only a rake task for first testing, should then be integrated in the
# user interface.
#
# See XXX.

desc "Translates .prg (FoxPro) files to erb."
task prg_to_erb: :environment do | t, args |
  args.with_defaults(:ifile => '../prg_to_erb/test2.prg', :ofile => nil)
  if args.ofile.nil?
    ofile = args.ifile + ".erb" 
  else
    ofile = args.ofile
  end
  puts "[+] ifile: #{args.ifile}\n[+] ofile: #{ofile}"

  code = nil
  File.open("#{Rails.root}/#{args.ifile}") do |fd|
    code = fd.readlines
  end
  if code.nil?
    puts "[error] no such file: '#{args.ifile}'"
    exit 1
  end

  # TODO: some header, declaring the current @projekt
  header = "<% @projekt = .... %>\n"

  t = Translator.new
  code = code.map{|c| t.translate c }

  File.open("#{Rails.root}/#{ofile}", 'w') do |fd|
    fd.write header
    # that 'chop' + \n is an fixes an awkward bug resulting in "^M\n"
    code.each{ |line| fd.write line.chop + "\n" if line != "" }
  end

end

##
# The Translator translates Foxpro's .prg-templates to erb templates.
# We use some db lookups to guess unknown columns.
class Translator
  attr_accessor :cols
  def initialize
    # If we use a column from buecher, we need to say '@projekt.buch.column',
    # thus we need to remember where we found the (hopefully correct) db entry.
    self.cols = {
      ''      => ActiveRecord::Base.connection.columns('gprods'),
      'buch.' =>  ActiveRecord::Base.connection.columns('buecher')
    }
  end

  def translate(code)
    # Find '=' signs that are used in prg's if(conditions) --> '=='
    m = /<<iif\((.*?),.*\)/.match code
    code.gsub! m[1], m[1].gsub(/\=/, ' == ') unless m.nil?

    # basic substitutions of FoxPro stuff with Ruby stuff
    dict = {
      /\*\*.*\n/ => '',      # Comments
      /^\s*TEXT\s*$/ => '',  # Some strange statement
      #/^%(?!%)/ => '%%',    # Not sure if we need this
      '<<' => '<%=',         # erb begin
      '>>' => '%>',          # erb end
    }.each{ |regex,substitution| 
      was_not_empty = ! code.empty?
      code.gsub! regex, substitution
      # if we create an empty line, delete it
      code.delete! if was_not_empty and code.empty?
    }

    # call to the parser, when we encounter foxpro code
    m = /<%=(.*)%>/.match code
    unless m.nil?
      fox_code = m[1].dup
      puts "[+] found codeblock: '''\n#{m[1]}\n'''"
      code.gsub!(m[1], parse(fox_code))
    end

    code
  end

  # Trying to find the equivalent entry in the new db to the old db entry.
  # Note: hint should be e{cip, zeit, autoren, reihen}.
  def find_id(hint, id)
    # XXX some db entries dont exist yet.. lets get them first..
    cols.each{ |prefix, entries|
    }
  end

  def parse(s)
    tokens = fox_tokenize(s)

    puts "[+] got token stream:"
    tokens.each{|t|
      puts " #{format("%10s", t.type)}\t->\t'#{t.str[0]}'"
    }

    r = ''
    tokens.each {|t|
      if t.type == :function
        r += Fox.send t.str
      end
    }
    r
  end

  # Produce usefully tokenized output for foxpro code.
  # Returns a token stream (array).
  def fox_tokenize(s)
    token_stream = []
    offset = 0
    patterns = [
      /(?<whitespace>\s+)/,
      /(?<keyword>iif)/,
      /(?<string>".*?")/,
      /(?<function>[a-z]+(?=\())/,
      /(?<id>[a-zA-Z_.]+(?!\())/,
      /(?<operator>[-+*!\/])/,
      /(?<separator>[,()])/,
      /(?<number>[0-9.]+)/,
    ]

    while true do
      token_string = nil

      patterns.each{ |pat|
        token_string = nil
        match = pat.match s[offset .. -1]

        # If group is not defined we didnt match and try the next pattern.
        token_string = match[pat.names[0]] rescue next

        # If we didnt match the immediately following token in the code..
        next if match.offset(0)[0] != 0

        # Get the Token and advance offset in the input string.
        tok = Token.new
        tok.str = token_string,
        tok.type = pat.names[0]
        token_stream << tok unless tok.type == 'whitespace'
        break
      }

      break if offset == s.length
      if token_string.nil?
        raise RuntimeError,
          "Could not tokenize whole expression: '#{s}'\n" + 
          "\tfailed at offset/strlen #{offset}/#{s.length}\n" +
          "\tlast tokens were: #{token_stream[-3..-1]}"
      end
      offset += token_string.length
    end


    token_stream
  end

  ##
  # This class contains only translations of foxpro functions.
  class Fox
    class << self
      def iif(cond, opta, optb)
        'if' + cond + 'then' + opta + 'else' + optb + 'end'
      end
      def str(s,len,wtf) ; '(' + s + ').to_s' end
      def strtran(s,a,b) ; s.sub a,b end
      def trim(s) ; s end # might be used to fix foxpro quirks
    end
  end # class Fox

end # class Translator

# Mini token class.
class Token
  attr_accessor \
    :str,
    :type
end
