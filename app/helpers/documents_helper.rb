module DocumentsHelper
  def status_to_string status
    if status == 0
      "Draft"
    elsif status == 1
      "For review"
    elsif status == 2
      "For approval"
    elsif status == 3
      "Effective"
    else
      "Unknown"
    end
  end

  def approval_status_to_string status
    if status == 0
      'Pending'
    elsif status == 1
      'Approved'
    elsif status == 2
      'Declined'
    else
      'Unknown'
    end
  end

  def review_status_to_string status
    if status == 0
      'Pending'
    elsif status == 1
      'Reviewed'
    else
      'Unknown'
    end
  end
end
