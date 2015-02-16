module DocumentsHelper
  def status_to_string status
    if status == 0
      "Draft"
    elsif status == 1
      "For review"
    elsif status == 2
      "For approval"
    elsif status == 3
      "Approved"
    else
      "Unknown"
    end
  end
end
