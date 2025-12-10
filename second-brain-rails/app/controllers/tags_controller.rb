class TagsController < ApplicationController
  def index
    @tags = Tag.all.order(:name)
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    
    if @tag.save
      redirect_to tags_path, notice: 'Tag created successfully.'
    else
      @tags = Tag.all.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    redirect_to tags_path, notice: 'Tag deleted.'
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end
