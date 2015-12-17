module ControllerHelper
  ##
  # Class is used to create a new hash with the params for the buch db commit
  # here the the format field which comes from the HTML form is changed from a string to the
  # belonging format
  def buch_params(permitted_params, array_of_formats,array_of_umschlaege,array_of_papiere)
    hash_of_params = permitted_params.to_h
    array_of_formats.each do |format|
     if hash_of_params[:format][:bezeichnung].eql?(format.bezeichnung) then hash_of_params[:format] = format end
    end
    array_of_umschlaege.each do |umschlag|
      if hash_of_params[:umschlag][:bezeichnung].eql?(umschlag.bezeichnung) then hash_of_params[:umschlag] = umschlag end
    end
    array_of_papiere.each do |papier|
      if hash_of_params[:papier][:bezeichnung].eql?(papier.bezeichnung) then hash_of_params[:papier] = papier end
    end
    return hash_of_params
  end

  ##
  # created by Rouven Glauert
  # this Method is used to take a the permitted_params hash and sort out all nil entries
  # ===Example
  def self.make_compact(params)
    hash = Hash.new
    params.each do |key, value|
      if not value.eql?("")
        hash[key] = value
      end
    end
    return hash
  end


end