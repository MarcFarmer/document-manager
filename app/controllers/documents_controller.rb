class DocumentsController < ApplicationController
  before_action :check_current_organisation

  def index
    @documents = Document.where(organisation_id: get_current_organisation.id)
  end

  def show
    @document = Document.find(params[:id])
    @user = @document.user
  end

  def new
    @document = Document.new
#    current_organisation = get_current_organisation
#    document_types = DocumentType.all.select {|d| d.organisation == current_organisation}
#    @document_types = document_types.each {|d| d.name}.zip(document_types.each {|d| d.id})
    @current_user_id = current_user.id
  end

  def create
    @document = Document.new(document_params)
    @document.organisation = get_current_organisation
    @document.status = 0

    if @document.save
      redirect_to action: 'index', notice: 'Document was successfully created.'
    else
      render action: 'new', alert: 'Document could not be created'
    end
  end

  def handle_status
    if params[:status] != nil   # view documents with different status
      new_status = status_to_int params[:status]
      @new_documents = Document.where organisation_id: get_current_organisation.id, status: new_status
      respond_to do |format|
        format.js
      end
    else
      status_change = params[:submit]
    end
  end

  private

  def document_params
    params.require(:document).permit(:doc, :document_type, :title, :user_id)
  end

  def check_current_organisation
    if get_current_organisation == nil
      redirect_to root_path, notice: "You must select an organisation before viewing documents."
    end
  end

  def status_to_int status
    if status == "Draft"
      0
    elsif status == "For review"
      1
    elsif status == "For approval"
      2
    elsif status == "Approved"
      3
    else    # unknown
      -1
    end
  end

end
