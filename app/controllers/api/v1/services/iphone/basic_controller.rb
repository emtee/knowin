class Api::V1::Services::Iphone::BasicController < ApplicationController
  def authenticate
    user = User.find_for_database_authentication(:username => params[:username])
    if user && user.valid_password?(params[:password])
      render :json => {
        :status   => true,
        :body     => user,
        :message  => "User authentication successfull."
      }
    else
      if user
        render :json => {
          :status   => false,
          :body     => @user,
          :message  => "User authentication failed."
        }
      else
        render :json => {
          :status   => false,
          :body     => nil,
          :message  => "Invalid Login Attempt. Username not found."
        }
      end
    end
  end

  def signup
    @user = User.new({
      :email    => params[:email],
      :username => params[:username], 
      :password => params[:password],
      :password_confirmation => params[:password_confirmation]})
    # if @user.save
    if @user.save
      render :json => {
        :status   => true,
        :body     => @user,
        :message  => "Account created successfully."
      }
    else
      render :json => {
        :status   => false,
        :body     => @user.errors,
        :message  => "Sorry your account couldn't be created. Please try again."
      }
    end
  end

  def get_datasets
    @user = User.find_by(username: params[:username]) rescue nil
    eval(params[:datasets_ids]).each do |dataset_id|
      if @user.dataset_ids.include?(dataset_id)
        puts dataset_id.inspect + " is already present."
      else
        # @user.datasets << Dataset.find_by(id: dataset_id)
        # @user.datasets.create(id: dataset_id)
        @user.datasets << Dataset.find_by(id: dataset_id) 
      end
    end if @user
    if @user && @user.save
      render :json => {
        :status   => true,
        :body     => nil,
        :message  => "Datasets added to your account successfully"
      }
    else
      render :json => {
        :status   => false,
        :body     => (@user.errors rescue nil),
        :message  => "Sorry there was some problem saving the datasets. Try again later."
      }
    end
  end

  def remove_datasets
    # Will do in next relelase
  end

  def update_settings
    @user = user.find_by(username: params[:username])
    @user.password = params[:password]
    @user.password_confirmation = params[:password]
    @user.dashboard = params[:dashboard]    
    if @user.save
      render :json => {
        :status   => true,
        :body     => @user,
        :message  => "Setting Updated Successfully."
      }
    else
      render :json => {
        :status   => false,
        :body     => @user.errors,
        :message  => "Setting update failed."
      }
    end
  end
end
