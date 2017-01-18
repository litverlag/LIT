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

  t = PrgToErb.new
  code = code.map{|c| t.translate c }

  File.open("#{Rails.root}/#{ofile}", 'w') do |fd|
    fd.write header
    # that 'chop' + \n is an fixes an awkward bug resulting in "^M\n"
    code.each{ |line| fd.write line.chop + "\n" if line != "" }
  end

end # task end

##
# The PrgToErb class translates Foxpro's .prg-templates to erb templates. We
# use some db lookups to guess unknown columns.
class PrgToErb
  attr_accessor :cols

  def initialize
		## Why you ask?
    # If we use a column from buecher, we need to say '@projekt.buch.column',
    # thus we need to remember where we found the (hopefully correct) db entry.
    self.cols = {
      ''      => ActiveRecord::Base.connection.columns('gprods'),
      'buch.' =>  ActiveRecord::Base.connection.columns('buecher')
    }

		# Token stream, will be filled with the tokens of one foxpro-code-line at a
		# time, so no need to initialize.
		@tokens = nil
  end

	##
	# Public API, call this with your foxpro-template-string as argument.
	##
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
      @tokens = tokenize(fox_code)
      code.gsub!(m[1], parse())
    end

    code
  end

  # Depth first recursive parsing. Uses the token-stream @tokens.
  def parse
    puts "[+] got token stream:"

    result = ''
		curr = @tokens[0]
    while curr
			lookahead = @tokens[1]
      puts " #{format "%10s", curr.type}\t->\t'#{curr.str[0]}'" # TODO why str[0] not str

      case curr.type
      when 'function'
        # Get argument count, and pass accoring amount of foxpro expression.
        case Fox.method(curr.str[0]).arity
        when 1 then Fox.send(curr.str[0], expr)
        when 2 then Fox.send(curr.str[0], expr, expr)
        when 3 then Fox.send(curr.str[0], expr, expr, expr)
				end

      when 'keyword'
        result += 'if'

      else
        result += curr.str[0]
      end # case curr.type

      curr = @tokens.next_tok
    end

    result
  end

	##
	# Get tokens from @tokens until get have a full foxpro expression
	# Returns a string translated by the parse method.
	def expr
	end

	##
  # Trying to find the equivalent entry in the new db to the old db entry.
  # Note: hint should be e{cip, zeit, autoren, reihen}.
  def find_id(hint, id)
    # XXX some db entries dont exist yet.. lets get them first..

		# First try to be smart about that hint
		case hint
		when 'cip', 'zeit'
		when 'autoren'
		when 'reihen'
		end

		# Last resort is to iterate though our db entries and check for similar
		# names
		unless result
			cols.each{ |prefix, entries|
			}
		end

		result
  end

	##
  # Produce usefully tokenized output for foxpro code.
  # Returns a token stream (array).
  def tokenize(s)
    token_stream = []
    offset = 0
    patterns = [
      /(?<whitespace>\s+)/,
      /(?<keyword>iif)/,
      /(?<string>".*?")/,
      /(?<function>[a-z]+(?=\())/,
      /(?<id>[a-zA-Z_.]+(?!\())/,
      /(?<operator>[-+*!\/])/,
      /(?<separator>[,])/,
      /(?<group>[()])/,
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

        # Get the Token ..
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
          "\tlast @tokens were: #{token_stream[-3..-1]}"
      end

      # .. and advance offset in the input string.
      offset += token_string.length
    end

		# Return token array as stream object.
    TokenStream.new(token_stream)
  end

  ##
  # This class contains only translations of foxpro functions.
  class Fox
    class << self
      def iif(cond, opta, optb)
        'if' + cond + 'then' + opta + 'else' + optb + 'end'
      end
      def str(s,len,wtf) 
        '(' + s + ').to_s'
      end
      def strtran(s,a,b) 
        s.sub a,b
      end
      def empty(s)
        s + ".empty?"
      end

      # dummys
      def trim(s)
        s
      end
      def uc(s)
        s
      end

    end
  end # class Fox

end # class PrgToErb

# Mini token class.
class Token
  attr_accessor \
    :str,
    :type
end

# Mini token stream class.
class TokenStream
	def initialize(array)
		@data = array
		@offset = 0
	end

	# istream
	def <<(tok)
		@data << tok
	end
	# ostream, alias to next_tok
	def >>(tok)
		tok = next_tok
	end

	# get next token
	def next_tok
		@offset += 1
		#raise IndexError, "end of token stream" if @offset == @data.length
		return nil if @offset == @data.length
		@data[@offset-1]
	end

	# pass some methods on to the data array..
	def length; @data.length end
	# Note: no range checking
	def [](n); @data[@offset+n] end
end

