module OrganisationsHelper
  def user_type_to_string type
    case type
      when 0
        'Quality'
      when 1
        'Basic'
      when 2
        'Owner'
      else
        'Unknown'
    end
  end
end
