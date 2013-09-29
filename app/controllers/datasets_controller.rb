class DatasetsController < ApplicationController
  before_filter :authenticate_user!
  protect_from_forgery

  def index
    @datasets = Dataset.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @datasets }
    end
  end

  def show
    @dataset = Dataset.find(params[:id])
    @dataset.init_model

    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @dataset.as_json(:methods => Dataset.content ) }
      format.json { render json: @dataset.to_json(:methods => :content ) }
    end
  end

  def new
    @dataset = Dataset.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dataset }
    end
  end

  def edit
    @no_upload  = true
    @dataset    = Dataset.find(params[:id])
  end

  def create
    respond_to do |format|
      result = Hash.new
      # begin
        result = Dataset.save_data_model params
      # rescue Exception => e
      #   puts e.inspect
      # end
      if result[:status] == "success"
        dataset_exists = Dataset.find_by(title: result[:dataset][:title]).present? rescue nil
        unless dataset_exists
          puts result[:dataset].inspect
          @dataset = Dataset.new(result[:dataset])
          puts @dataset.inspect
          @dataset.save!
        else
          @dataset = Dataset.find_by(title: result[:dataset][:title])
        end
        format.html { redirect_to @dataset, notice: 'Dataset was successfully created.' }
      else
        @dataset = Dataset.new(params[:dataset])
        flash[:error] = 'There was some problem saving this dataset. Please verify the Source File & its contents. (Allowed extensions .xls | .csv)'
        format.html { render action: "new" }
      end
    end
  end

  def update
    @dataset    = Dataset.find(params[:id])
    @no_upload  = true

    respond_to do |format|
      if @dataset.update_attributes(params[:dataset])
        format.html { redirect_to @dataset, notice: 'Dataset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @dataset = Dataset.find(params[:id])
    model_full_filename = Rails.root + "app/models/" + @dataset.model_filename
    # raise File.exists?(model_full_filename).inspect
    eval(@dataset.model_classname).destroy_all
    File.delete(model_full_filename) #if File.exists?(model_full_filename)
    @dataset.destroy
    redirect_to datasets_url, notice: "Dataset was destroyed successfully."
  end
end
