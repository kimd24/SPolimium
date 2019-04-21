require 'test_helper'

class LegislatorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get legislators_index_url
    assert_response :success
  end

end
