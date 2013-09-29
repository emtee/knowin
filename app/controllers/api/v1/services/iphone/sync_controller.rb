class Api::V1::Services::Iphone::SyncController < ApplicationController
  def dashboard_content
    render :json => {
      "recently_viewed"   => Dataset.all,
      "most_popular"      => Dataset.all,
      "newly_added"       => Dataset.all
    }
  end

  def recently_viewed
    @user = User.find_by(username: params[:username]) rescue nil
    if @user
      render :json  => @user.recently_viewed_datasets
    else
      render :json => []
    end
  end

  def most_popular
    Dataset.update_user_count
    render :json => Dataset.most_popular.as_json(
      :only => [:_id, :title, :description]
      )
  end

  def newly_added
    render :json => Dataset.newly_added.as_json(
      # :except => [:model_classname, :model_filename, :created_at, :updated_at ]
      :only => [:_id, :title, :description]
      )
  end

  def dataset_details
    @dataset  = Dataset.find(params[:id]) rescue nil
    @user     = User.find_by(username: params[:username]) rescue nil
    @user.update_recent_views(@dataset) if @dataset && @user
    render :json  => @dataset.as_json({
      :only       => [:_id, :title, :description, :user_count],
      :methods    => :content
      })
  end

  def my_datasets
    @user     = User.find_by(username: params[:username]) rescue nil
    if @user
      render :json => @user.datasets.as_json(
        :only => [:_id, :title, :description]
        )
    else
      render :json => []
    end
  end

end
