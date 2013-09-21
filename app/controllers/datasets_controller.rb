class DatasetsController < ApplicationController

  def index
    @datasets = Dataset.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @datasets }
    end
  end

  def show
    @dataset = Dataset.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dataset }
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
    @dataset = Dataset.find(params[:id])
  end

  def create
    respond_to do |format|
      result = Dataset.save_data_model params
      if result[:status] == "success"
        @dataset = Dataset.new(result[:dataset])
        @dataset.save
        format.html { redirect_to @dataset, notice: 'Dataset was successfully created.' }
      else
        @dataset = Dataset.new(params[:dataset])
        format.html { render action: "new" }
      end
    end
  end

  def update
    @dataset = Dataset.find(params[:id])

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
    @dataset.destroy

    respond_to do |format|
      format.html { redirect_to datasets_url }
      format.json { head :no_content }
    end
  end
end
