  ##
  # Contains costum helpers to create faster views
module CostumViewHelper


  ##
  # This method is used to create statusbars for a costum status
  # === Example
  #
  #   status_bar(@projekt, @projekt.statusfinal.status, "Finaler Status")
  #


  def status_bar(instance_of_projekt,status, name_of_status)

    render "/views_for_helpers/status", status: status, name: name_of_status, projekt: instance_of_projekt
  end


  ##
  # This method is used to create a Panel with a set of infos.
  # The array has to have the
  # === Example
  #
  #   info_panel(@projekt, relevant_attr, names)
  def change_names_in_hash(relevant_attr, names)
    i= 0
    relevant_attr.keys.each do |key|
      if i < names.length
        relevant_attr[names[i]] = relevant_attr.delete key
        i = i+1
      else
        relevant_attr[key] = relevant_attr.delete key
      end

    end
    return relevant_attr
    #render "/views_for_helpers/info_panel", projekt_instance: projekt_instance, relevant_attr: relevant_attr, names: names
  end



end