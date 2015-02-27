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
    @document.document_revisions.build
    setup_new
  end

  def create
    @document = Document.new(document_params)
    @document.organisation = get_current_organisation
    @document.status = @@STATUS_DRAFT

    if @document.save
      # continue, create relations
    else
      setup_new
      render action: 'new', alert: 'Document could not be created'
      return
    end

    if params[:reviews] != nil
      reviewerArray = params[:reviews]
      reviewerArray.each do |blah, action|
        next if blah.blank?
        blah2 = Review.new
        blah2.user_id = blah.to_i
        blah2.document = @document
        blah2.status = 0
        blah2.save

        #TODO: Send email for reviewer assignment
        #Notifier.assign_role(email,doc_name,creator,role)
        # Notifier.assign_role(User.find(blah2.user_id).email,@document.title,User.find(@document.user_id).name,'Reviewer')

      end
    end

    if params[:approvals] != nil
      approvalArray = params[:approvals]
      approvalArray.each do |blah, action|
        next if blah.blank?
        blah2 = Approval.new
        blah2.user_id = blah.to_i
        blah2.document = @document
        blah2.status = 0
        blah2.save

        #TODO: Send email for approver assignment
        #Notifier.assign_role(email,doc_name,creator,role)
        # Notifier.assign_role(User.find(blah2.user_id).email,@document.title,User.find(@document.user_id).name,'Approver')
      end
    end

    if params[:document][:assigned_to_all] != nil
      if params[:readers] != nil
        readerIds = params[:readers]
        readerIds.each do |id, action|
          next if id.blank?
          r = Reader.new
          r.user_id = id.to_i
          r.document = @document
          r.save
        end
      end
    end

    @document.major_version = "0"
    @document.minor_version = "1"
    @document.do_update = false
    @document.change_control = "Initial creation."

    redirect_to action: 'index', notice: 'Document was successfully created.'
  end

  def edit
    @document = Document.find(params[:id])
    if @document.user != current_user
      flash[:warning] = 'You can only edit documents that are in the Draft state.'
      redirect_to action: 'index'
    end
    if @document.status != 0
      flash[:warning] = 'You can only edit documents that are in the Draft state.'
      redirect_to action: 'index'
    end
    setup_edit
  end

  def update
    @document = Document.find(params[:id])

    if @document.do_update == true
      @document_revision = DocumentRevision.new(major_version: @document.major_version, minor_version: @document.minor_version, content: @document.content,
                                                change_control: @document.change_control, document_id: @document.id)

      @document.minor_version = (@document.minor_version.to_i + 1).to_s
      @document.do_update = false

      @document_revision.save
    end

    if @document.update(document_params)
      if @document.assigned_to_all != true
        current_readers = Reader.where document: @document
        current_reader_ids = current_readers.collect {|r| r.user.id}
        if params[:reviews] != nil
          readerArray = params[:readers].keys.collect {|p| p.to_i}
        else
          readerArray = []
        end

        # check for any id that exists in current relations, but not in selection. Remove relation with this id
        (current_reader_ids - readerArray).each do |id|
          Reader.find_by_document_id_and_user_id(@document.id, id).destroy
        end

        # check for any id that exists in new relations, but not in selection. Create relation with this id
        (readerArray - current_reader_ids).each do |id|
          Reader.create(user_id: id, document: @document)
        end
      end


      current_reviews = Review.where document: @document
      current_reviewer_ids = current_reviews.collect {|r| r.user.id}
      if params[:reviews] != nil
        reviewerArray = params[:reviews].keys.collect {|p| p.to_i}
      else
        reviewerArray = []
      end

      # check for any id that exists in current relations, but not in selection. Remove relation with this id
      (current_reviewer_ids - reviewerArray).each do |id|
        Review.find_by_document_id_and_user_id(@document.id, id).destroy
      end

      # check for any id that exists in new relations, but not in selection. Create relation with this id
      (reviewerArray - current_reviewer_ids).each do |id|
        Review.create(user_id: id, document: @document, status: 0)
      end


      current_approvals = Approval.where document: @document
      current_approver_ids = current_approvals.collect {|a| a.user.id}
      if params[:reviews] != nil
        approverArray = params[:approvals].keys.collect {|p| p.to_i}
      else
        approverArray = []
      end

      # check for any id that exists in current relations, but not in selection. Remove relation with this id
      (current_approver_ids - approverArray).each do |id|
        Approval.find_by_document_id_and_user_id(@document.id, id).destroy
      end

      # check for any id that exists in new relations, but not in selection. Create relation with this id
      (approverArray - current_approver_ids).each do |id|
        Approval.create(user_id: id, document: @document, status: 0)
      end

      redirect_to action: 'show', notice: 'Document was successfully updated.'
    else
      setup_edit
      render action: 'edit', alert: 'Document could not be updated.'
    end
  end

  def destroy
    @document = Document.find(params[:id])
    if @document.destroy
      flash[:success] = 'Document was successfully deleted.'
    else
      flash[:danger] = 'Document was not deleted.'
    end
    redirect_to documents_path
  end

  def revision
    @document = Document.find(params[:id])
    @revision = DocumentRevision.find_by_document_id_and_major_version_and_minor_version params[:id], params[:major], params[:minor]
    if @revision == nil
      setup_show
      flash[:warning] = "#{@document.title} revision #{params[:major]}.#{params[:minor]} was not found."
      redirect_to document_path(params[:id])
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

          if d.status == @@STATUS_DRAFT
            d.do_update = true
          end
          
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
    if params[:decline] == nil
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


        document = a.document
        @document_revision = DocumentRevision.new(major_version: document.major_version, minor_version: document.minor_version, content: document.content,
                                                  change_control: document.change_control, document_id: document.id)
        @document_revision.save

        document.major_version = (document.major_version.to_i + 1).to_s
        document.minor_version = "0"
        document.save

        # TODO: Send email to creator of document to notify of approval
        # Notifier.doc_status(email,doc_name,outcome);
        # Notifier.doc_status(User.find(document.user_id).email,document.name,'Approved').deliver_now

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
    @document_revisions = DocumentRevision.where(document_id: @document.id)

    @reader_users = []

    commontator_thread_show(@document)

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
    # user can assign themself to roles. to disable this, add: .where.not(user_id: current_user.id)
    organisation_users = OrganisationUser.where(organisation_id: get_current_organisation.id, accepted: true)
    @users = []
    @users_to_select = []
    organisation_users.each do |ou|
      user = ou.user
      @users << [user.email, user.id]
      @users_to_select << user
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
    organisation_users = OrganisationUser.where(organisation_id: current_org_id, accepted: true)
    @users = []
    @users_to_select = []
    @existing_approver_ids = []
    @existing_reviewer_ids = []

    organisation_users.each do |ou|
      user = ou.user
      @users << [user.email, user.id]
      @users_to_select << user
      if Approval.exists?(document: @document, user: user)
        @existing_approver_ids << user.id
      end
      if Review.exists?(document: @document, user: user)
        @existing_reviewer_ids << user.id
      end
    end

    @current_user_id = current_user.id

    @document_types = Hash.new
    org_doc_types = DocumentType.where(organisation_id: get_current_organisation.id)
    org_doc_types.each do |item|
      @document_types.merge!(item.name.to_sym => item.id)
    end
  end

  def document_params
    # params.require(:document).permit(:assigned_to_all, :content, :doc, :document_type_id, :title, :user_id,
    #                                  document_revisions_attributes: [:change_control])
    params.require(:document).permit(:assigned_to_all, :content, :doc, :document_type_id, :title, :user_id,
                                     :change_control)
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
