class FoldersController < ApplicationController
  before_action :set_folder, only: %i[ show update destroy ]

  # GET /folders
  def index
    @folders = Folder.all

    render json: @folders
  end

  # GET /folders/1
  def show
    render json: @folder
  end

  # POST /folders
  def create
    @folder = Folder.new(folder_params)

    if @folder.save
      render json: @folder, status: :created, location: @folder
    else
      render json: @folder.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /folders/1
  def update
    @folder = Folder.find(params[:id])
    if (params.has_key?(:new_id))
      new = @folder.contains
      if new.include?(params[:new_id])
        new.delete(params[:new_id])
      else
        new.append(params[:new_id])
      end
      Folder.update(params[:id], :contains => new)
      @folders = Folder.where(id: current_user.user_feed.folders)
      render json: @folders
    else
      render json: @folder.errors, status: :unprocessable_entity
    end
  end

  # DELETE /folders/1
  def destroy
    @folder.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = Folder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def folder_params
      params.require(:folder).permit(:name, :contains)
    end
end
