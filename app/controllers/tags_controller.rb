class TagsController < ApplicationController
  def show
    if user_signed_in?
      @articles = (Article.tagged_with [params[:id]]).paginate(page: params[:page], :per_page => 5)
    else
      @articles = (Article.tagged_with [params[:id]]).not_draft.paginate(page: params[:page], :per_page => 5)
    end 
  end

  def index  
  end
end
