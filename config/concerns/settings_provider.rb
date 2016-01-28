## SettingsProvider
#
#   The Class gives the possibility to import true or false settings in from a yaml file and is used to give configurate
#   the views for each departement.
#
#   The class offers three interfaces
          # get_all_options
          # all_coloum_names
          # names_and_types
#
#
#
class SettingsProvider
  ##
  #     filename
  #     The name of the yaml file to import the settings it has to have the following structure
  #           options:
  #               department1: [true,true,true]
  #               department2: [true,false,true]
  #
  #     tables
  #     Tables are the names of the tables to which correspond to the options
  #

  def initialize(filename,table,name_in_yml)
    import(filename,table,name_in_yml)
  end

  ##
  # returns a hash table of all db fields and the corrensponding option
  def get_all_options
    @all_options
  end

  ##
  # returns an array which all fields from all selected databases
  def all_coloum_names
    @all_names
  end

  ##
  # return a hash table with all field names for each table and its corresponding db types
  def names_and_types
    @names_and_types
  end

  def add_attributes(department,name,type)
    @all_names.append(name)
    @names_and_types.store(name.to_sym,type)
    @all_options[department].store(name.to_sym,nil)
  end

  def set_options(department,name,option)
    @all_options[department][name] = option
  end
  def change_type(name,new_type)
    @names_and_types[name] = new_type
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
    def import(filename,table_name,name_in_yaml)
      yam = YAML.load_file(Rails.root.join(filename))
      @all_names = get_table_fields(table_name)
      @names_and_types = get_field_types(table_name)
      #write_legend!(filename,names)
      yam[name_in_yaml].each do |deparment|
        if not deparment.second.nil?
          @all_options = {}
          @all_options[deparment.first] = make_hash_from_two_arr(@all_names,deparment.second)
        end
      end
    end

    def write_legend!(filename,coloum_names)
      f = File.open filename, 'r'
      file = f.read
      new_string = file.gsub(/#fields.*/,"#fields##{coloum_Names.length}#{coloum_names}")
      f.close
      File.truncate(filename, 0)
      File.open(filename, 'r+'){ |f|
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