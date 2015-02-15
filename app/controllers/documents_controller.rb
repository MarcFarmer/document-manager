class DocumentsController < ApplicationController
  def index
    @documents = Document.all
  end

  def new
    @document = Document.new
    @current_user_id = current_user.id
  end

  def create
    @document = Document.new(document_params)

    if @document.save
      redirect_to action: 'index', notice: 'Document was successfully created.'
    else
      render action: 'new', alert: 'Document could not be created'
    end
  end

  private

  def document_params
    params.require(:document).permit(:doc, :title, :user_id)
  end

end
