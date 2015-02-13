class OrganisationsController < ApplicationController
  def index
    o = Organisation.new(name: "zzzzz")
    o.save
    @organisations = Organisation.all     # TODO
    @current_organisation = get_current_organisation
  end
end
