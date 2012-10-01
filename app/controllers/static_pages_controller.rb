class StaticPagesController < ApplicationController
  def home
    if user_signed_in?
      @articles = Article.paginate(page: params[:page], :per_page => 5)
    else
      @articles = Article.not_draft.paginate(page: params[:page], :per_page => 5)
    end     
  end
  
  def search
    @pg_search_articles = PgSearch.multisearch(params[:search]).paginate(page: params[:page],                                                                          
                                                                         per_page: 5)
  end
end
