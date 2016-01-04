require 'singleton'
##
# Created by Rouven Glauert
# This class provides all standart options for things like papier, formate, ...
# You access the options by 
# ==== How to acces the values
#
#      ChoosableOption.instance.format :all
#      ChoosableOption.instance.format :a4
#
# To create a new type of option like "format" or "papier" you have to add it to the options.yml file
# Then restart the server to initialize the new options

class ChoosableOption
  include Singleton

  ##
  # Contains all possible options and gets filled once when initializing the server
  ALL_OPTIONS = {}



  #_____________ABOVE THIS LINE_______


  def make_options_hash(data)
    unless data.nil?
      t_array1 = []
      data.each do |value|
        t_array1.push([value.to_sym,value])
      end
      # The final hash options has to have this structure {{:a4,"a4"},{:a3,"a3"},..}
      t_array1.to_h
    end
  end

  ##
  # This method takes the Hash and converts it into a array with all options
  #
  def make_array_of_all(data)
    array_of_all_options = []
    data.each do |key,value|
      array_of_all_options.append(value)
    end
    return array_of_all_options
  end

  ##
  # This method imports the data from an external file it is called once at the initialization of the server
  #
  def import

    yam = YAML.load_file(Rails.root.join('config/options.yml'))

    yam["options"].each do |type_of_option|
      ALL_OPTIONS[type_of_option.first] = make_options_hash(type_of_option.second)
    end


  end


  ##
  # This method takes the type of options like "format" and a symbol like :a4 to return the corresponding value
  # if you take :all as the symbol argument you get an array of all possible options for this type
  #
  #
  def get_option(type_of_option, symbol)
    options = ALL_OPTIONS[type_of_option]

    if symbol.eql? :all
      make_array_of_all(options)
    else
      if not options[symbol]
        raise ArgumentError, "the choosen option :#{symbol} is not available in the options :#{type_of_option}"
      end
      options[symbol]
    end
  end

  ##
  # Method the acces the format options
  ChoosableOption.instance.import
  ALL_OPTIONS.each do |key,value|
    define_method key do |symbol|
      get_option(key,symbol)
    end
  end



end
