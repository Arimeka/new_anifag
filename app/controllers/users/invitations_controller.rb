# coding: utf-8
class Users::InvitationsController < Devise::InvitationsController 
    
  def update
    super
    if @user
      @user.create_user_description(role: "user")
    end
  end  
end 