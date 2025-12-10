class AttachmentsController < ApplicationController
  before_action :set_note
  before_action :set_attachment, only: [:destroy]
  
  def create
    @attachment = @note.attachments.build(attachment_params)
    
    if params[:attachment][:file].present?
      @attachment.file.attach(params[:attachment][:file])
    end
    
    if @attachment.save
      redirect_to @note, notice: 'File uploaded successfully.'
    else
      redirect_to @note, alert: "Upload failed: #{@attachment.errors.full_messages.join(', ')}"
    end
  end
  
  def destroy
    @attachment.destroy
    redirect_to @note, notice: 'Attachment deleted.'
  end
  
  private
  
  def set_note
    @note = Note.find(params[:note_id])
  end
  
  def set_attachment
    @attachment = @note.attachments.find(params[:id])
  end
  
  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
