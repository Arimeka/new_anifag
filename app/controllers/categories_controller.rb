# coding: utf-8
class CategoriesController < ApplicationController
  before_filter :correct_user,   only: [:edit, :update, :destroy, :new, :create, :index]
  
  def index
    @categories = Category.paginate(page: params[:page])    
  end
  
  def show
    @category = Category.find(params[:id])
    if user_signed_in? 
      @articles = @category.articles.paginate(page: params[:page], :per_page => 5)
    else
      @articles = @category.articles.not_draft.paginate(page: params[:page], :per_page => 5)
    end
  end
  
  def new
    @category = Category.new    
  end
  
  def create
    name = Russian.translit(params[:category]["name"]).downcase
    @category = Category.new(name: name, title: params[:category]["title"], 
                             description: params[:category]["description"])
    if @category.save
      flash[:success] = "Категория создана."
      redirect_to categories_path
    else
      render 'new'
    end
  end
  
  def edit
    @category = Category.find(params[:id])
  end
  
  def update
    @category = Category.find(params[:id])
    name = Russian.translit(params[:category]["name"]).downcase
    if @category.update_attributes(name: name, title: params[:category]["title"], 
                                   description: params[:category]["description"])
      flash[:success] = "Категория обновлена."
      redirect_to categories_path
    else
      render 'edit'
    end
  end
  
  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    flash[:success] = "Категория удалена."
    redirect_to categories_path
  end
  
  private    
    
    def correct_user
      redirect_to root_path unless (user_signed_in? && current_user.admin?)
    end
end
