# coding: utf-8
class Users::RegistrationsController < Devise::RegistrationsController 
    
  def new
    redirect_to root_path
  end 
  
  def create
    redirect_to root_path
  end 

  def update
    user = User.find(current_user.id)

    if params[:user][:password].blank?
      params[:user][:password] = params[:user][:current_password]
      params[:user][:password_confirmation] = params[:user][:current_password]
    end

    if user.update_with_password(params[:user])
      user.user_description.update_attributes(links: params[:links], sign: params[:sign])
      sign_in user, :bypass => true
      redirect_to user
    else
      clean_up_passwords user
      respond_with user
    end
  end 
end 