class DocumentsController < ApplicationController
  before_action :check_current_organisation

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

  def check_current_organisation
    if get_current_organisation == nil
      redirect_to root_path, notice: "You must select an organisation before viewing documents."
    end
  end

end
