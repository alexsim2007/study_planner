require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "registration page is available" do
    get register_path

    assert_response :success
  end

  test "user can register with valid data" do
    assert_difference("User.count", 1) do
      post register_path, params: {
        user: {
          name: "Alexander",
          email: "new@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
    follow_redirect!

    assert_response :success
    assert_match "Alexander", response.body
  end

  test "user cannot register with invalid data" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          name: "",
          email: "",
          password: "123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "user is logged in after registration" do
    post register_path, params: {
      user: {
        name: "Alexander",
        email: "login_after_register@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_redirected_to root_path

    get root_path

    assert_response :success
    assert_match "Alexander", response.body
  end
end