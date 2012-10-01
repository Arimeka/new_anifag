# coding: utf-8
class TopicPostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :correct_user, only: [:edit]
  before_filter :admin_user, only: [:index]
  
  def index
    @topic_posts = TopicPost.paginate(page: params[:page], :per_page => 30)
  end

  def edit
    @topic_post = TopicPost.find(params[:id])
  end
  
  def create
    @topic = Topic.find(params[:topic])
    if !@topic.close
      @topic_post = current_user.topic_posts.build(content: params[:topic_post]["content"], topic_id: params[:topic].to_i)    
      @topic_posts = @topic.topic_posts.last(20)
      if params[:preview_button] || !@topic_post.save
        render 'topics/show'
      else
        if @topic_post.save
          @topic.update_attributes(last_post_at: @topic_post.created_at)
          flash[:success] = "Пост создан."
          redirect_to @topic_post.topic
        else
          render 'topics/show'
        end
      end
    else
      flash[:error] = "Комментирование запрещено."
      redirect_to @topic
    end
  end
  
  def update
    @topic_post = TopicPost.find(params[:id])
    if params[:preview_button]
      render 'edit'
    elsif params[:cancel_button]
      redirect_to @topic_post.topic
    else    
      if @topic_post.update_attributes(params[:topic_post])
        flash[:success] = "Пост обновлен."
        redirect_to @topic_post.topic
      else
        render 'edit'
      end
    end
  end

  def destroy
    @topic_post.destroy
    flash[:success] = "Пост удален."
    redirect_to forums_url
  end
  
  private
    def correct_user
      if params[:id]
        @topic_post = TopicPost.find(params[:id])
      else 
        @topic_post = current_user.topic_posts.build()
      end      
      user = @topic_post.user
      redirect_to forums_path unless ((current_user?(user) && !current_user.banned) || current_user.admin?)
    end
    
    def admin_user
      redirect_to forums_path unless current_user.admin?
    end
end
