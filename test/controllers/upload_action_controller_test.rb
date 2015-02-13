require 'test_helper'

class UploadActionControllerTest < ActionController::TestCase
  test "should get uploadIndex" do
    get :uploadIndex
    assert_response :success
  end

end
