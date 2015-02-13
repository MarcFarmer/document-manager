class DocumentsController < ApplicationController
  def index
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.create( document_params )
  end

  private

  def document_params
    params.require(:user).permit(:doc)
  end

end
