class DocumentsController < ApplicationController
  before_action :check_current_organisation

  def index
    @documents = Document.where(organisation_id: get_current_organisation.id, status: 0, user_id: current_user.id)    # view draft documents by current user default
    if get_document_filter == nil
      set_document_filter "all_documents"
    end
    if get_status_filter == nil
      set_status_filter 0
    end
  end

  def show
    @document = Document.find(params[:id])
    @user = @document.user
  end

  def new
    @document = Document.new
    current_user_id = current_user.id
    current_org_id = get_current_organisation.id
    organisation_users = OrganisationUser.where(organisation_id: current_org_id, accepted: true).where.not(user_id: current_user_id)
    @users = []
    organisation_users.each do |ou|
      user = ou.user
      @users << [user.email, user.id]
    end
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
      new_status = status_change_to_int params[:status]
      @new_documents = Document.where organisation_id: get_current_organisation.id, status: new_status
      respond_to do |format|
        format.js
      end
    else    # change status of one or more documents
      if params[:selected_documents] != nil   # at least one document selected
        new_status = status_change_to_int params[:submit]
        old_status = Document.find(params[:selected_documents].keys[0].to_i).status
        params[:selected_documents].each do |doc_id, select_action|
          d = Document.find(doc_id.to_i)
          d.status = new_status
          d.save
        end

        @new_documents = Document.where organisation_id: get_current_organisation.id, status: old_status
        respond_to do |format|
          format.js
        end
      end
    end
  end

  def your_documents
    set_document_filter "your_documents"
  end

  def your_actions
    set_document_filter "your_actions"
  end

  def all_documents
    set_document_filter "all_documents"
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

  def status_change_to_int status
    if status == "Draft"
      0
    elsif status == "Send for review" || status == "For review"
      1
    elsif status == "Send for approval"  || status == "For approval"
      2
    elsif status == "Approved"
      3
    else    # unknown
      -1
    end
  end

  def set_document_filter filter
    session[:document_filter] = filter
  end

  def get_document_filter
    session[:document_filter]
  end

  def set_status_filter filter
    session[:status_filter] = filter
  end

  def get_status_filter
    session[:status_filter].to_i
  end

  def get_filtered_documents
    # check document and status filters
    if get_document_filter == "your_actions"
      org_id = get_current_organisation.id
      if get_status_filter == 1 # for review
        documents_for_review = []
        reviews = Review.where user_id: user_id
        reviews.each do |r|
          if r.document.organisation_id == org_id
            documents_for_review << r.document
          end
        end
        documents_for_review
      elsif get_status_filter == 2 # for approval
        documents_for_approval = []
        approvals = Approval.where user_id: user_id
        approvals.each do |a|
          if a.document.organisation_id == org_id && a.document.status == 2
            documents_for_approval << a.document
          end
        end
        documents_for_approval
      elsif get_status_filter == 3 # approved
        documents_approved = []
        approvals = Approval.where user_id: user_id
        approvals.each do |a|
          if a.document.organisation_id == org_id && a.document.status == 3
            documents_approved << a.document
          end
        end
        documents_approved
      end
    else
      where_hash = {organisation_id: get_current_organisation.id, status: get_status_filter}
      if get_document_filter == "your documents"  # do nothing if all documents
        where_hash[:user_id] = current_user.id
      end
      Documents.where(where_hash)
    end
  end

end
