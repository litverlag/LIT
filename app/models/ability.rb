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
    if @departName.include?'Superadmin'
      can :manage, :all
    else
      can [:read, :update], AdminUser.find(user.id)
    end
    if @departName.include?'Umschlag'
      can [:read, :update], Um
    end
    if @departName.include?'Satz'
      can [:read, :update], SReif
    end
    if @departName.include?'Titelei'
      can [:read, :update], Tit
    end
    if @departName.include?'PrePs'
      can [:read, :update], Preps
    end
    if @departName.include?'Rechnung'
      # can :manage, :all
    end
    if @departName.include?'Bildprüfung'
      # can :manage, :all
    end
    if @departName.include?'Lektor'
      can :crud, Projekt
    end
    if @departName.include?'Pod'
      can [:read, :update], :Druck
    end
    if @departName.include?'Binderei'
      can [:read, :update], :Bi
    end

    can :manage, :all #TODO remove this can :manage :all
    can :read, ActiveAdmin::Page, :name => "Dashboard"
    can :read, ActiveAdmin::Page, :name => "Access_denied"

  end
end