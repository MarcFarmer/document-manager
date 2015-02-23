class DocumentsController < ApplicationController
  @@DF_YOUR_DOCUMENTS = "your_documents"
  @@DF_YOUR_ACTIONS = "your_actions"
  @@DF_ALL_DOCUMENTS = "all_documents"

  before_action :check_current_organisation

  def index
    if get_document_filter == nil
      set_document_filter @@DF_YOUR_DOCUMENTS
    end
    if get_status_filter == nil
      set_status_filter 0
    end
    @documents = get_filtered_documents    # view draft documents by current user default
    @initial_document_filter = get_document_filter
    @initial_status_filter = get_status_filter
  end

  def show
    setup_show
  end

  def new
    @document = Document.new
    setup_new
  end

  def create
    @document = Document.new(document_params)
    @document.organisation = get_current_organisation
    @document.status = 0

    reviewerArray = params[:document][:reviews]
    reviewerArray.each do |blah|
      next if blah.blank?
      blah2 = Review.new
      blah2.user_id = blah.to_i
      blah2.document = @document
      blah2.status = 0
      blah2.save
    end

    approvalArray = params[:document][:approvals]
    approvalArray.each do |blah|
      next if blah.blank?
        blah2 = Approval.new
      blah2.user_id = blah.to_i
      blah2.document = @document
      blah2.status = 0
      blah2.save
    end

    if @document.save
      redirect_to action: 'index', notice: 'Document was successfully created.'
    else
      setup_new
      render action: 'new', alert: 'Document could not be created'
    end
  end

  def edit
    @document = Document.find(params[:id])
    if @document.user != current_user
      redirect_to action: 'index', notice: 'You can only edit documents that you created.'
    end
    setup_edit
  end

  def update
    @document = Document.find(params[:id])

    if @document.update(document_params)
      # also update reviewers and approvers
      reviewerArray = params[:document][:reviews]
      reviewerArray.each do |blah|
        next if blah.blank?
        blah2 = Review.new
        blah2.user_id = blah.to_i
        blah2.document = @document
        blah2.status = 0
        blah2.save
      end

      approvalArray = params[:document][:approvals]
      approvalArray.each do |blah|
        next if blah.blank?
        blah2 = Approval.new
        blah2.user_id = blah.to_i
        blah2.document = @document
        blah2.status = 0
        blah2.save
      end

      redirect_to action: 'show', notice: 'Document was successfully updated.'
    else
      setup_edit
      render action: 'edit', alert: 'Document could not be updated.'
    end
  end

  def handle_status
    if params[:status] != nil   # view documents with different status
      set_status_filter status_change_to_int params[:status]
      @new_documents = get_filtered_documents
      respond_to do |format|
        format.js
      end
    else    # change status of one or more documents
      if params[:selected_documents] != nil   # at least one document selected
        new_status = status_change_to_int params[:submit]
        params[:selected_documents].each do |doc_id, select_action|
          d = Document.find(doc_id.to_i)
          d.status = new_status
          d.save
        end

        @new_documents = get_filtered_documents
        respond_to do |format|
          format.js
        end
      end
    end
  end

  def your_documents
    set_document_filter @@DF_YOUR_DOCUMENTS
    @new_documents = get_filtered_documents
    render 'handle_status.js.erb'
  end

  def your_actions
    set_document_filter @@DF_YOUR_ACTIONS
    @new_documents = get_filtered_documents
    render 'handle_status.js.erb'
  end

  def all_documents
    set_document_filter @@DF_ALL_DOCUMENTS
    @new_documents = get_filtered_documents
    render 'handle_status.js.erb'
  end

  def save_role_response
    success = ''
    if params[:approve] != nil
      a = Approval.find params[:relation_id].to_i
      a.status = 1
      a.save
      success = 'You have approved this document.'
    elsif params[:decline] != nil
      a = Approval.find params[:relation_id].to_i
      a.status = 2
      a.save
      success = 'You have declined this document.'
    elsif params[:review] != nil
      r = Review.find params[:relation_id].to_i
      r.status = 1
      r.save
      success = 'You have marked this document as reviewed.'
    end

    setup_show
    flash[:success] = success
    render :show
  end

  private

  def setup_show
    @document = Document.find(params[:id])
    @user = @document.user

    @review_users = []

    reviews = Review.where(document_id: @document.id)
    reviews.each do |r|
      @review_users << {review: r, user: r.user}
    end

    @approval_users = []

    approvals = Approval.where(document_id: @document.id)
    approvals.each do |a|
      @approval_users << {approval: a, user: a.user}
    end

    @review = Review.find_by_user_id_and_document_id current_user.id, @document.id
    @approval = Approval.find_by_user_id_and_document_id current_user.id, @document.id
    if @document.status == 1 && @review != nil
      @is_reviewer = true
      @relation_id = @review.id
    elsif @document.status == 2 && @approval != nil
      @is_approver = true
      @relation_id = @approval.id
    end
  end

  def setup_new
    current_user_id = current_user.id
    current_org_id = get_current_organisation.id
    organisation_users = OrganisationUser.where(organisation_id: current_org_id, accepted: true).where.not(user_id: current_user_id)
    @users = []
    organisation_users.each do |ou|
      user = ou.user
      @users << [user.email, user.id]
    end

    @current_user_id = current_user.id

    @document_types = Hash.new
    org_doc_types = DocumentType.where(organisation_id: get_current_organisation.id)
    org_doc_types.each do |item|
      @document_types.merge!(item.name.to_sym => item.id)
    end
  end

  def setup_edit
    @edit = true

    current_user_id = current_user.id
    current_org_id = get_current_organisation.id
    organisation_users = OrganisationUser.where(organisation_id: current_org_id, accepted: true).where.not(user_id: current_user_id)
    @users = []
    organisation_users.each do |ou|
      user = ou.user
      @users << [user.email, user.id]
    end

    @current_user_id = current_user.id

    @document_types = Hash.new
    org_doc_types = DocumentType.where(organisation_id: get_current_organisation.id)
    org_doc_types.each do |item|
      @document_types.merge!(item.name.to_sym => item.id)
    end
  end

  def document_params
    params.require(:document).permit(:content, :doc, :document_type_id, :title, :user_id)
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
    if get_document_filter == @@DF_YOUR_ACTIONS
      org_id = get_current_organisation.id
      if get_status_filter == 0 # draft, you have been assigned as a reviewer or approver
        documents_for_approval_or_review = []
        reviews = Review.where user_id: current_user.id
        reviews.each do |r|
          if r.document.organisation_id == org_id && r.document.status == 0
            documents_for_approval_or_review << r.document
          end
        end
        approvals = Approval.where user_id: current_user.id
        approvals.each do |a|
          if a.document.organisation_id == org_id && a.document.status == 0
            documents_for_approval_or_review << a.document
          end
        end
        documents_for_approval_or_review
      elsif get_status_filter == 1 # for review
        documents_for_review = []
        reviews = Review.where user_id: current_user.id
        reviews.each do |r|
          if r.document.organisation_id == org_id && r.document.status == 1
            documents_for_review << r.document
          end
        end
        documents_for_review
      elsif get_status_filter == 2 # for approval
        documents_for_approval = []
        approvals = Approval.where user_id: current_user.id
        approvals.each do |a|
          if a.document.organisation_id == org_id && a.document.status == 2
            documents_for_approval << a.document
          end
        end
        documents_for_approval
      elsif get_status_filter == 3 # approved
        documents_approved = []
        approvals = Approval.where user_id: current_user.id
        approvals.each do |a|
          if a.document.organisation_id == org_id && a.document.status == 3
            documents_approved << a.document
          end
        end
        documents_approved
      end
    else
      where_hash = {organisation_id: get_current_organisation.id, status: get_status_filter}
      if get_document_filter == @@DF_YOUR_DOCUMENTS  # do nothing if all documents
        where_hash[:user_id] = current_user.id
      end
      print where_hash
      Document.where(where_hash)
    end
  end
end
