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

	# TODO need some header, declaring @projekt
	header = '<% @projekt = .... %>'

	t = Translator.new
	code = code.map{|c| t.translate c }

	File.open("#{Rails.root}/#{ofile}", 'w') do |fd|
		fd.write header
		code.each{ |line| fd.write line }
	end

end

class Translator
	attr_accessor :cols
	def initialize
		# if we use a column from buecher, we need to say '@projekt.buch.column'
		self.cols = ['gprods', 'buecher'].map{|name|
			[name, ActiveRecord::Base.connection.columns(name)]
		}
	end

	def translate(code)
		# find '=' signs that are used in if(conditions)
		m = /<<iif\((.*?),.*\)/.match code
		code.gsub! m[1], m[1].gsub(/\=/, ' == ') unless m.nil?

		# find db entries
		m = /([a-z]+)\.([a-z_]+)/.match code
		unless m.nil?
			hint = m[1]
			id = m[2]
			new_db_name = find_id(hint, id)
			code.gsub! m[0], new_db_name unless new_db_name.nil?
		end

		# basic substitutions of FoxPro stuff with Ruby stuff
		dict = {
			/\*\*.*\n/ => '',
			/iif\((.*?),(.*?),(.*?)\)/ => 'if \1 then \2 else \3 end',
			'<<' => '<%=',
			'>>' => '%>',
			/^\s*TEXT\s*$/ => '',
			/uc\((.*?)\)/ => '\1'
		}.each{ |regex,substitution| 
			was_not_empty = ! code.empty?

			code.gsub! regex, substitution

			# if we create an empty line, delete it
			if was_not_empty and code.empty?
				code.delete!
			end
		}

		code
	end

	def find_id(hint, id)
		# XXX some db entries dont exist yet.. lets get them first..
	end
end
