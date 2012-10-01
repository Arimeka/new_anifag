class ArchivesController < ApplicationController
  def show
    if params[:month]
      if params[:month] == '12'
        @articles = Article.end_year(params[:year], params[:month]).not_draft.paginate(page: params[:page], :per_page => 10)
      else
        @articles = Article.last_month(params[:year], params[:month]).not_draft.paginate(page: params[:page], :per_page => 10)
      end
    else
      @articles_archive_list = Article.last_year(params[:year]).not_draft.group_by { |post| Russian::strftime(post.created_at, "%B") }
    end
  end
end
