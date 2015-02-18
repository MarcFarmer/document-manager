class DocumentTypesController < ApplicationController
  before_action :check_current_organisation
  before_action :all_document_types, only: [:index, :create]
  respond_to :html, :js

  # GET /document_types
  # GET /document_types.json
  def index
    @document_types = DocumentType.where(organisation_id: get_current_organisation.id)
    @document_type = DocumentType.new
  end

  # GET /document_types/1
  # GET /document_types/1.json
  # def show
  # end

  def new
    @document_type = DocumentType.new
  end

  # GET /document_types/1/edit
  # def edit
  # end

  def create
    @document_type = DocumentType.new(name: params[:create][:name], organisation_id: get_current_organisation.id)
    @document_type.save

    respond_to do |format|
      format.js
    end
  end

  # # PATCH/PUT /document_types/1
  # # PATCH/PUT /document_types/1.json
  # def update
  #   respond_to do |format|
  #     if @document_type.update(document_type_params)
  #       format.html { redirect_to @document_type, notice: 'Document type was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @document_type }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @document_type.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /document_types/1
  # # DELETE /document_types/1.json
  def destroy
    DocumentType.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to document_types_url, notice: 'Document type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def all_document_types
    @document_types = DocumentType.where(organisation_id: get_current_organisation.id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # def document_type_params
  #   params.require(:document_type).permit(:name)
  # end
end
