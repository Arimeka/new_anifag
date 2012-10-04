# coding: utf-8
class ArticlesController < ApplicationController
  before_filter :authenticate_user!, except: [:show ,:index, :redirect_to_new]
  before_filter :correct_user,   except: [:show ,:index, :redirect_to_new]
    
  def show
    if user_signed_in?
      @article = Article.find(params[:id]) || Article.find_by_permalink(id)
    else
      @article = Article.not_draft.find_by_id(params[:id]) || Article.not_draft.find_by_permalink(id)
    end  
  end
  
  def redirect_to_new
    if user_signed_in?
      @article = Article.find_by_permalink(params[:id])
    else
      @article = Article.not_draft.find_by_permalink(params[:id])
    end
    redirect_to @article     
  end
  
  def index
    @articles = Article.limit(25)
    
    respond_to do |format|
      format.html do
        redirect_to root_path
      end
      format.rss do
        unless request.env['HTTP_USER_AGENT'] =~ /feedburner/i
          redirect_to 'http://feeds.feedburner.com/AnimeFag'
        end
      end
    end
  end
  
  def new   
  end
  
  def edit    
    @article = Article.find(params[:id])
    if @article.description != @article.content
      params[:content] = @article.description + "<hr id=\"more\">" + @article.content.split(@article.description)[1]
    else
      params[:content] = @article.content
    end
    
    params[:title] = @article.title
    params[:description] = @article.description
    params[:source] = @article.source
    params[:keywords] = @article.keywords
    params["meta-description"] = @article.meta_description
    params[:permalink] = @article.permalink
    
    if @article.tags
      params[:tags] = @article.tags.join(',')
    end
    
    if @article.categories.any?
      params[:categories] = []
      @article.categories.each do |x|
        params[:categories].push(x.name)
      end
    end
  end

  def create
    post_content(params[:content])
    
    if params[:keywords].blank?
      params[:keywords] = params[:tags]
    end 

    if params[:permalink].blank?
      slug = Russian.translit(params[:title]).downcase.split.map do |x|
        x[/\S+/]
      end.join('-')
    else
      slug = Russian.translit(params[:permalink].downcase.split.map do |x|
        x[/\S+/]
      end.join('-')
    end
    
    if params["meta-description"].blank?
      if Sanitize.clean(@mass[0]).length > 160
        params["meta-description"] = Sanitize.clean(@mass[0])[0..160] + '...'
      elsif Sanitize.clean(@mass[0]).length > 50
        params["meta-description"] = Sanitize.clean(@mass[0])[0..160]
      else
        params["meta-description"] = ''
      end
    end
          
    @article = current_user.articles.build(content: @mass[0]+@mass[1], description: @mass[0], 
                                           title: params[:title], source: params[:source], 
                                           keywords: params[:keywords], meta_description: params["meta-description"],
                                           permalink: slug, draft: false, tags: params[:tags].split(/,\s*/))    
                                                                                     
    if params[:preview_button] || !@article.save
      render 'new'
    elsif params[:draft_button] || !@article.save
      @article.draft = true 
      if @article.save
        if params[:categories]
          unless params[:categories].include?('')
            params[:categories].each do |x|
              name = Russian.translit(x).downcase.split.map { |n| n[/\w+/] }.join('-')
              if Category.find_by_name(name)
                @article.categories << Category.find_by_name(name)
              else
                @article.categories.create(name: name, title: x)

              end
            end
          end 
        end        
        
        flash.now[:success] = "Пост сохранен."
        redirect_to edit_article_path(@article)
      else
        render 'new'
      end     
    else
      if @article.save
        if params[:categories]
          unless params[:categories].include?('')
            params[:categories].each do |x|
              name = Russian.translit(x).downcase.split.map { |n| n[/\w+/] }.join('-')
              if Category.find_by_name(name)
                @article.categories << Category.find_by_name(name)
              else
                @article.categories.create(name: name, title: x)
              end
            end
          end 
        end        
        
        flash[:success] = "Пост создан!"
        redirect_to current_user
      else
        render 'new'
      end
    end
  end
  
  def update
    @article = Article.find(params[:id])
    post_content(params[:content])
    
    if params[:keywords].blank?
      params[:keywords] = params[:tags]
    end
    
    if params[:permalink].blank?
      slug = Russian.translit(params[:title]).downcase.split.map do |x|
        x[/\S+/]
      end.join('-')
    else
      slug = Russian.translit(params[:permalink].downcase.split.map do |x|
        x[/\S+/]
      end.join('-')
    end

    @article.content = @mass[0]+@mass[1]
    @article.description = @mass[0]
    @article.title = params[:title]
    @article.source = params[:source]
    @article.keywords = params[:keywords]
    @article.meta_description = params["meta-description"]
    @article.permalink = slug
    @article.tags = params[:tags].split(/,\s*/)
    
    if params[:categories]
      @article.categories.delete_all
      unless params[:categories].include?('')
        params[:categories].each do |x|
          name = Russian.translit(x).downcase.split.map { |n| n[/\w+/] }.join('-')
          if Category.find_by_name(name)
            @article.categories << Category.find_by_name(name)
          else            
            @article.categories.create(name: name, title: x)
          end
        end
      end      
    end 
    
    if params[:preview_button] || !@article.save
      render 'edit'
    elsif params[:draft_button] || !@article.save
      @article.draft = true 
      if @article.save
        flash.now[:success] = "Пост сохранен в черновики."
        render 'edit'
      else
        render 'edit'
      end
    else
      @article.draft = false            
      if @article.save
        flash[:success] = "Пост обновлен!"
        redirect_to @article
      else
        render 'edit'
      end
    end
  end

  def destroy
    @article.destroy
    flash[:success] = "Пост удален."
    redirect_to root_url
  end
  
  private
    def post_content(content)
      @mass = []
      if content.index("<hr id=\"more\">")
        @mass = content.split("<hr id=\"more\">")
      else
        @mass[0] = content
        @mass[1] = ''
      end
    end 
    
    def correct_user
      if params[:id]
        @article = Article.find(params[:id])
      else 
        @article = current_user.articles.build()
      end
      user = @article.user
      redirect_to(root_path) unless ((current_user?(user) && !current_user.banned) || current_user.admin? || user_editor?(current_user))
    end
end
