class Ability
  include CanCan::Ability

  def initialize(user)
    #abort("Message goes here")
    user ||= User.new # guest user
    #abort('some user')
    if user.user_role.eql?'Admin'
      can :manage, :all
    elsif user.user_role.eql?'Druck'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :read, ActiveAdmin::Page, :name => "Access_denied"
      can :manage, Lf
    elsif user.user_role.eql?'Lektor'

      
    
     
    end
  end
end