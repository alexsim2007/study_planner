require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user can be created with valid data" do
    user = User.new(
      name: "Alexander",
      email: "alex@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?
  end

  test "password is stored as a digest" do
    user = User.create!(
      name: "Alexander",
      email: "alex@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_not_equal "password123", user.password_digest
    assert user.authenticate("password123")
  end

  test "email must be unique" do
    User.create!(
      name: "Alexander",
      email: "alex@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    second_user = User.new(
      name: "Another User",
      email: "alex@example.com",
      password: "password456",
      password_confirmation: "password456"
    )

    assert_not second_user.valid?
  end

  test "email is normalized" do
    user = User.create!(
      name: "Alexander",
      email: "  ALEX@EXAMPLE.COM  ",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_equal "alex@example.com", user.email
  end
end