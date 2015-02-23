module ApplicationHelper
  @@USER_TYPE_QUALITY = 0
  @@USER_TYPE_BASIC = 1
  @@USER_TYPE_OWNER = 2

  def user_type_to_string type
    case type
      when @@USER_TYPE_QUALITY
        'Quality'
      when @@USER_TYPE_BASIC
        'Basic'
      when @@USER_TYPE_OWNER
        'Owner'
      else
        'Unknown'
    end
  end

  def is_owner type
    type == @@USER_TYPE_OWNER ? true : false
  end

  def is_quality type
    type == @@USER_TYPE_QUALITY ? true : false
  end

  def is_basic type
    type == @@USER_TYPE_BASIC ? true : false
  end
end
