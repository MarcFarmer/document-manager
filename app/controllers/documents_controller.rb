class DocumentsController < ApplicationController
  @@DF_YOUR_DOCUMENTS = 'your_documents'
  @@DF_YOUR_ACTIONS = 'your_actions'
  @@DF_ALL_DOCUMENTS = 'all_documents'

  @@STATUS_DRAFT = 0
  @@STATUS_FOR_REVIEW = 1
  @@STATUS_FOR_APPROVAL = 2
  @@STATUS_APPROVED = 3

  before_action :check_current_organisation

  def index
    if get_document_filter == nil
      set_document_filter @@DF_YOUR_DOCUMENTS
    end
    if get_status_filter == nil
      set_status_filter @@STATUS_DRAFT
    end
    @documents = get_filtered_documents # view draft documents by current user default
    @initial_document_filter = get_document_filter
    @initial_status_filter = get_status_filter
    @current_user_is_basic = is_basic(OrganisationUser.where(organisation: get_current_organisation, user: current_user)[0].user_type)
  end

  def show
    setup_show
  end

  def new
    if is_basic(OrganisationUser.where(organisation: get_current_organisation, user: current_user)[0].user_type)
      redirect_to :documents, notice: 'Basic user accounts cannot create documents.'
    end

    @document = Document.new
    setup_new
  end

  def create
    @document = Document.new(document_params)
    @document.organisation = get_current_organisation
    @document.status = @@STATUS_DRAFT

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

    if params[:document][:assigned_to_all] != nil
      readerIds = params[:document][:readers]
      readerIds.each do |id|
        next if id.blank?
        r = Reader.new
        r.user_id = id.to_i
        r.document = @document
        r.save
      end
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
    if params[:status] != nil # view documents with different status
      set_status_filter status_change_to_int params[:status]
      @new_documents = get_filtered_documents
      respond_to do |format|
        format.js
      end
    else # change status of one or more documents
      if params[:selected_documents] != nil # at least one document selected
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
    # password is filtered in params log by Devise gem
    if params[:email] != current_user.email || !current_user.valid_password?(params[:password])   # if wrong email or password
      if params[:review] != nil
        document = Review.find(params[:relation_id].to_i).document
        flash[:danger] = 'Incorrect email or password.'
        setup_show
        redirect_to documents_path + "/#{document.id}"
        return
      else
        document = Approval.find(params[:relation_id].to_i).document
        setup_show
        flash[:danger] = 'Incorrect email or password.'
        redirect_to documents_path + "/#{document.id}"
        return
      end
    end

    success = ''
    if params[:approve] != nil
      a = Approval.find params[:relation_id].to_i
      a.status = 1
      a.save
      success = 'You have approved this document.'

      # if all approvers have approved the document, make it effective
      approvals = Approval.where(document: a.document).where.not(status: 1)   # approvals where status != approved
      if approvals.empty?
        a.document.update(status: 3)    # document is now effective
      end
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

    @reader_users = []

    readers = Reader.where(document: @document)
    readers.each do |r|
      @reader_users << {reader: r, user: r.user}
    end

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
    if @document.status == @@STATUS_FOR_REVIEW && @review != nil
      @is_reviewer = true
      @relation_id = @review.id
    elsif @document.status == @@STATUS_FOR_APPROVAL && @approval != nil
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
    params.require(:document).permit(:assigned_to_all, :content, :doc, :document_type_id, :title, :user_id)
  end

  def check_current_organisation
    if get_current_organisation == nil
      redirect_to root_path, notice: "You must select an organisation before viewing documents."
    end
  end

  def status_change_to_int status
    if status == "Draft" || status == "Revert to draft"
      0
    elsif status == "Send for review" || status == "For review"
      1
    elsif status == "Send for approval" || status == "For approval"
      2
    elsif status == "Effective"
      3
    else # unknown
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
      if get_status_filter == @@STATUS_DRAFT # draft, you have been assigned as a reviewer or approver
        get_documents_for_review | get_documents_for_approval
      elsif get_status_filter == @@STATUS_FOR_REVIEW
        get_documents_for_review
      elsif get_status_filter == @@STATUS_FOR_APPROVAL
        get_documents_for_approval
      elsif get_status_filter == @@STATUS_APPROVED
        get_approved_documents
      end
    else
      if get_document_filter == @@DF_YOUR_DOCUMENTS
        Document.where(organisation_id: get_current_organisation.id, status: get_status_filter, user_id: current_user.id)
      elsif get_document_filter == @@DF_ALL_DOCUMENTS
        user_type = OrganisationUser.where(user: current_user, organisation: get_current_organisation)[0].user_type
        if is_owner(user_type)
          Document.where(organisation_id: get_current_organisation.id, status: get_status_filter)
        else # for non-owner user, show document if user is: creator / reader / approver / reviewer
          case get_status_filter
            when @@STATUS_DRAFT # your documents and documents where you are a reader
              get_your_documents(@@STATUS_DRAFT) | get_reader_documents(@@STATUS_DRAFT)
            when @@STATUS_FOR_REVIEW # your documents and documents where you are a reviewer
              get_your_documents(@@STATUS_FOR_REVIEW) | get_documents_for_review | get_reader_documents(@@STATUS_FOR_REVIEW)
            when @@STATUS_FOR_APPROVAL # your documents and documents where you are an approver
              get_your_documents(@@STATUS_FOR_APPROVAL) | get_documents_for_approval | get_reader_documents(@@STATUS_FOR_APPROVAL)
            when @@STATUS_APPROVED # your documents and documents where you are an approver, and document is approved
              get_your_documents(@@STATUS_APPROVED) | get_approved_documents | get_reader_documents(@@STATUS_APPROVED)
          end
        end
      end
    end
  end

  def get_documents_for_review
    documents_for_review = []
    reviews = Review.where user_id: current_user.id
    reviews.each do |r|
      if r.document.organisation == get_current_organisation && r.document.status == @@STATUS_FOR_REVIEW
        documents_for_review << r.document
      end
    end
    documents_for_review
  end

  def get_documents_for_approval
    documents_for_approval = []
    approvals = Approval.where user_id: current_user.id
    approvals.each do |a|
      if a.document.organisation == get_current_organisation && a.document.status == @@STATUS_FOR_APPROVAL
        documents_for_approval << a.document
      end
    end
    documents_for_approval
  end

  def get_approved_documents
    documents_approved = []
    approvals = Approval.where user_id: current_user.id
    approvals.each do |a|
      if a.document.organisation == get_current_organisation && a.document.status == @@STATUS_APPROVED
        documents_approved << a.document
      end
    end
    documents_approved
  end

  def get_your_documents status
    Document.where(organisation_id: get_current_organisation.id, status: status, user_id: current_user.id)
  end

  def get_reader_documents status
    documents = Document.where(organisation: get_current_organisation, status: status)
    reader_documents = []
    documents.each do |d|
      if d.assigned_to_all || Reader.where(user: User.first, document: Document.first).count > 0
        reader_documents << d
      end
    end
    reader_documents
  end
end
