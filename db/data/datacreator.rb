class RailsTestDataCreator
     #20
 
    def initialize
        ActiveRecord::Base.connection
        Rails.application.eager_load!
    end

    def create_database_entry()
    
        ActiveRecord::Base.connection.tables.each do |table_name| 
            ActiveRecord::Base.connection.columns(table_name).each do|column_name|                
                ActiveRecord::Base.descendants.each do |model|
                    if (/#{model}/i.match(table_name) != nil)
                        puts "#{model} #{column_name.name}  "
                        model.create(get_data_array(table_name.to_s,column_name.name,column_name.type.to_s))
                    end
                end
            end
        end
    end

    def get_data_array(table_name,column_name,type)

        filename = "#{table_name}_#{column_name}__#{type}"
        file = File.new("db/data/#{filename}", "r")
        data_array = []
        
        if (/__[\w]+/.match(filename).to_s == "__binary") 
            p = Proc.new{|line| line.unpack("B*")}
        elsif (/__[\w]+/.match(filename).to_s == "__boolean") 
            p = Proc.new{|line| true if line=="true"; false if false=="false"}
        elsif (/__[\w]+/.match(filename).to_s == "__date") 
             p = Proc.new{|line| Date.strptime(line, '%d-%m-%Y')}
        elsif (/__[\w]+/.match(filename).to_s == "__datetime") 
             p = Proc.new{|line|  DateTime.rfc2822(line)}
        elsif (/__[\w]+/.match(filename).to_s == "__decimal")
             p = Proc.new{|line|  BigDecimal.new(line) }
        elsif (/__[\w]+/.match(filename).to_s == "__float")
            p = Proc.new{|line|  line.to_f}
        elsif (/__[\w]+/.match(filename).to_s == "__integer")
            p = Proc.new{|line|  line.to_i}
        elsif (/__[\w]+/.match(filename).to_s == "__string")
            p = Proc.new{|line|  line}
        elsif (/__[\w]+/.match(filename).to_s == "__text")
            p = Proc.new{|line|  line}
        elsif (/__[\w]+/.match(filename).to_s == "__timestamp")
            p = Proc.new{|line|  DateTime.rfc2822(line)}
        end

        while(line = file.gets)
             data = p.call(line)
             data_hash = {column_name.to_sym => data}
             data_array.push(data_hash)
        end

        file.close
        return data_array
    
    end

    def self.make_files
        ActiveRecord::Base.connection.tables.each do |table_name|
            ActiveRecord::Base.connection.columns(table_name).each do|column_name|
                File.new("db/data/#{table_name.to_s}_#{column_name.name}__#{column_name.type.to_s}","w+")
            end
        end
    end
end

