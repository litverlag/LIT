###
#
# The Class gives the possibility to import true or false settings in from a yaml file and is used to give configurate
# the views for each departement.
#
# The name of the yaml file to import the settings it has to have the following structure
#   options:
#      department1: [true,true,true]
#      department2: [true,false,true]
#

class SettingsProvider
  ###
  # *filename*
  # filename is the name and path of the yaml in which the options are saved
  #
  # *table*
  # is either the name of the table of the database to get the fields or an hash  in this form
  #         table = {"name_of_field": :"type_of field", ... }
  #         table = {"statusbildpr": :"selectable", "statusbinderei": :"selectable"}
  # *name_in_yaml*
  # is the name of the of the hash in the yaml file on the first level of nesting
  #
  def initialize(filename,table,name_in_yml)
    @filename = filename
    @name_in_yml = name_in_yml
    if table.is_a? String
      if ActiveRecord::Base.connection.tables.include?(table)
        import(filename,table,name_in_yml)
      else

      end
    elsif table.is_a? Hash
      import(filename,table,name_in_yml)
    else
      raise ArgumentError, "The paramater table must be either a string with the tablename or a Hash in this form "
    end
  end

  ##
  # Returns an Hash table which all possible fields and the corresponding true or false option.
  # The field are either from the table you have chosen when initialising an instance or from the hash you have given as a parameter or from the database.
  # The options come from the yaml file.
  def get_all_options
   return @all_options
  end

  ##
  # Returns an array which all possible fields. They are either from the table you have chosen when initialising an instance or from the hash you have given as a parameter.
  def all_coloum_names
    @all_names
  end

  ##
  # Returns an Hash table which all possible fields and the corresponding type.
  # The fields and types come either from the table you have chosen when initialising an instance or from the hash you have given as a parameter or from the database.
  def names_and_types
    @names_and_types
  end

  # def add_attributes(department,name,type)
  #   @all_names.append(name)
  #   @names_and_types.store(name.to_sym,type)
  #   @all_options[department].store(name.to_sym,nil)
  # end
  #
  # def set_options(department,name,option)
  #   @all_options[department][name] = option
  # end

   def change_type(name,new_type)
     @names_and_types[name] = new_type
   end

  def remove_attribute(name)
      @all_options.each do |key,dep|
       dep.delete(name.to_sym)
      end
      @all_names.delete name
      @names_and_types.each do |key,dep|
        dep.delete(name)
      end
  end



  begin
    private
    @all_names
    @all_options
    @names_and_types
    @filename
    @name_in_yml
    ##
    # This methods takes to Arrays and makes a hash table with the first array as the keys and the second as the values
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
            raise ArgumentError, "Array of keys length #{keys.length} must equal Array of values length #{values.length} "
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
    #
    def import(filename,table_name,name_in_yaml)
      yam = YAML.load_file(Rails.root.join(filename))
      if table_name.is_a? Hash
        # In this case table name is alrey
        t_names = []
        table_name.each {|key,value| t_names.append key}
        @all_names = t_names
        @names_and_types = table_name
      else
        @all_names = get_table_fields table_name
        @names_and_types = get_field_types table_name
      end
      write_legend!
      @all_options ={}
      yam[name_in_yaml].each do |department|
        if not department.second.nil?
          @all_options[department.first] = make_hash_from_two_arr(@all_names,department.second)
        end
      end

    end

    def write_legend!
      f = File.open @filename, 'r'
      file = f.read
      new_string = file.gsub(/#fields##{@name_in_yml}.*/,"#fields##{@name_in_yml}##{@all_names.length}#{@all_names}")
      f.close
      File.truncate(@filename, 0)
      File.open(@filename, 'r+'){ |f|
        f.write new_string
      }
    end


    ##Returns an array with all the column names
    #
    #     get_table_field(array_of_table_names)
    #
    def get_table_fields(table_name)

      array_of_names = []
      ActiveRecord::Base.connection.columns(table_name).each do |c|
        array_of_names.append c.name
      end
      array_of_names
    end



    # #
    # Returns a hash table with all the field and the corresponding types
    #
    def get_field_types(table_name)
      array_of_names = []
      array_of_types = []

        ActiveRecord::Base.connection.columns(table_name).each do |c|
          array_of_names.append c.name
          array_of_types.append c.type.to_s
        end

      make_hash_from_two_arr(array_of_names,array_of_types)
    end


  end
end