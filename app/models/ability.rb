class Ability
  include CanCan::Ability

  def initialize(user)
    #abort("Message goes here")
    user ||= User.new # guest user
    #abort('some user')

    @departName = []
    #depart = user.departments.to_a
    user.departments.to_a.each do |a|
        @departName.append a.name
    end


    #TODO Rechte für alle Benutzergruppen eintragen
    if @departName.include?'superadmin'
      can :manage, :all
    end
    if @departName.include?'Umschlag'
      can :read, :ums
    end
    if @departName.include?'Satz'
      can :read, :s_reifs
    end
    if @departName.include?'Titelei'
      can :read, :lves
    end
    if @departName.include?'PrePs'
      can :read, :preps
    end
    if @departName.include?'Rechnung'
      can
    end
    if @departName.include?'Bildprüfung'
      can
    end
    if @departName.include?'Lektor'
      can
    end
    if @departName.include?'Pod'
      can
    end
    if @departName.include?'Binderei'
      can :read, :bis
    end


    can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :read, ActiveAdmin::Page, :name => "Access_denied"
  end
end