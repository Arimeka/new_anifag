# coding: utf-8
class TopicsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :correct_user, except: [:show]
  before_filter :admin_user, only: [:index]
  
  def index    
    @topics = Topic.paginate(page: params[:page], :per_page => 30)
  end

  def create
    forum = Forum.find(params[:forum])
    if forum.protect && !current_user.admin?
      flash[:error] = "Создание топиков запрещено."
      redirect_to forum
    end
    if forum.title == 'Новости и объявления'
      title = Time.now.strftime("%Y-%m-%d") + ' - ' + params[:topic]["title"]
    else
      title = params[:topic]["title"]
    end    
    @topic = current_user.topics.build(title: title, 
                                       content: params[:topic]["content"], 
                                       forum_id: params[:forum].to_i,
                                       last_post_at: Time.now)    
    if params[:preview_button] || !@topic.save
      render 'new'
    else
      if @topic.save
        flash[:success] = "Топик создан."
        redirect_to @topic
      else
        render 'new'
      end
    end
  end

  def new
    forum = Forum.find(params[:forum])
    if forum.protect && !current_user.admin?
      flash[:error] = "Создание топиков запрещено."
      redirect_to forum
    end
    @topic = Topic.new    
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def show
    @topic = Topic.find(params[:id])
    @topic_post = current_user.topic_posts.build if user_signed_in? && !@topic.close
    query =  @topic.topic_posts
    if params[:page]
      @topic_posts = query.paginate(page: params[:page], :per_page => 20)
    else
      last_page = query.paginate(page: params[:page], :per_page => 20).total_pages
      @topic_posts = query.paginate(page: last_page, :per_page => 20)
    end   
  end

  def update
    @topic = Topic.find(params[:id])
    if params[:preview_button]
      render 'edit'
    elsif params[:cancel_button]
      redirect_to @topic
    else    
      if @topic.update_attributes(params[:topic])
        flash[:success] = "Топик обновлен."
        redirect_to @topic
      else
        render 'edit'
      end
    end
  end

  def destroy
    @topic.destroy
    flash[:success] = "Топик удален."
    redirect_to forums_url
  end
  
  private
    def correct_user
      if params[:id]
        @topic = Topic.find(params[:id])
      else 
        @topic = current_user.topics.build()
      end      
      user = @topic.user
      redirect_to forums_path unless ((current_user?(user) && !current_user.banned) || current_user.admin?)
    end
    
    def admin_user
      redirect_to forums_path unless current_user.admin?
    end
end
