# coding: utf-8
class UsersController < ApplicationController
  before_filter :admin_user,         only: [:index, :ban]
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def show
    @user = User.find(params[:id])
    @articles = @user.articles.paginate(page: params[:page], per_page: 15)
  end
    
  def ban
    @user = User.find(params[:id])
    if current_user.admin? && !current_user?(@user) && !@user.admin?      
      @user.toggle!(:banned)
      if @user.banned == true
        flash[:success] = "Пользователь забанен."
      else
        flash[:success] = "Пользователь разабанен."
      end
      redirect_to @user
    else
      redirect_to(root_path)
    end
  end
    
  private    
    
    def admin_user
      redirect_to forums_path unless current_user.admin?
    end
end
