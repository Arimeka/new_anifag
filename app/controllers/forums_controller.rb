# coding: utf-8
class ForumsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :correct_user, except: [:index ,:show]
  
  def index
    @forums = Forum.all
  end

  def show
    @forum = Forum.find(params[:id])
    @topics = @forum.topics.paginate(page: params[:page], :per_page => 30) 
  end
  
  def new    
    @forum = Forum.new  
  end
  
  def create
    @forum = current_user.forums.build(params[:forum])
    
    if @forum.save
      flash[:success] = "Форум создан."
      redirect_to @forum
    else
      render 'new'
    end
  end
  
  def edit
    @forum = Forum.find(params[:id])    
  end
  
  def update
    @forum = Forum.find(params[:id])    
    if @forum.update_attributes(params[:forum])
      flash[:success] = "Форум обновлен."
      redirect_to @forum
    else
      render 'edit'
    end    
  end
  
  def destroy
    @forum.destroy
    flash[:success] = "Форум удален."
    redirect_to forums_url    
  end
  
  private
    def correct_user
      redirect_to forums_path unless current_user.admin?
    end
end
