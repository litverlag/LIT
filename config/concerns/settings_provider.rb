class SettingsProvider

  def initialize(filename,tables)
    import(filename,tables)
    #write_legend Rails.root.join(filename), names
  end


  def get_all_options
    @all_options
  end


  def all_coloum_names
    @all_names
  end

  def names_and_types
    @names_and_types
  end


  begin
    private
    @all_names
    @all_options
    @names_and_types

    ##
    # This methods takes to Arrays and makes a hash table with the first array as the keys and the second as the values
    #
    #
    def make_hash_from_two_arr(keys,values)
      unless values.nil?
        t_array1 = []
        i = 0
        if keys.nil?
          values.each do |value|
            t_array1.push([value.to_sym,value])
          end
        else
          if not keys.length == values.length
            raise ArgumentError, "The array for the names has to have the same length as the one for the options. see options.yml"
          end
          values.each do |value|
            t_array1.push([keys[i].to_sym,value])
            i = i + 1
          end
        end
        t_array1.to_h
      end
    end

    ##
    # This method imports the data from an external file it is called once at the initialization of the server
    def import(filename,tablenames)
      yam = YAML.load_file(Rails.root.join(filename))
      names = get_table_fields(tablenames)
      write_legend!(filename,names)
      yam["options"].each do |type_of_option|
        if not type_of_option.second.nil?
          @all_options = {}
          @all_options[type_of_option.first] = make_hash_from_two_arr(names,type_of_option.second)
        end
      end
    end

    def write_legend!(filename,coloum_Names)
      f = File.open filename, 'r'
      file = f.read
      new_string = file.gsub(/#fields.*/,"#fields##{coloum_Names.length}#{coloum_Names}")
      f.close
      File.truncate(filename, 0)
      File.open(filename, 'r+'){ |f|
        f.write new_string
      }
    end


    ##Return one array with all the column names.
    #
    #     get_table_field(array_of_table_names
    #
    def get_table_fields(tablenames)
      array_of_names = []
      array_of_types = []
      tablenames.each do |tablename|
        ActiveRecord::Base.connection.columns(tablename).each do |c|
          array_of_names.append c.name
          array_of_types.append c.type
        end
      end
      @names_and_types = make_hash_from_two_arr(array_of_names,array_of_types)
      @all_names = array_of_names
    end
  end

end