require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Alexander",
      email: "alex@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "login page is available" do
    get login_path

    assert_response :success
  end

  test "user can login with correct password" do
    post login_path, params: {
      session: {
        email: "alex@example.com",
        password: "password123"
      }
    }

    assert_redirected_to root_path

    follow_redirect!

    assert_response :success
    assert_match "Alexander", response.body
  end

  test "user cannot login with incorrect password" do
    post login_path, params: {
      session: {
        email: "alex@example.com",
        password: "wrong_password"
      }
    }

    assert_response :unprocessable_entity
    assert_match "Неверный email или пароль", response.body
  end

  test "user cannot login with unknown email" do
    post login_path, params: {
      session: {
        email: "unknown@example.com",
        password: "password123"
      }
    }

    assert_response :unprocessable_entity
    assert_match "Неверный email или пароль", response.body
  end

  test "user can logout" do
    post login_path, params: {
      session: {
        email: "alex@example.com",
        password: "password123"
      }
    }

    delete logout_path

    assert_redirected_to login_path

    get root_path

    assert_redirected_to login_path
  end
end