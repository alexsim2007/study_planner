require "test_helper"

class SubjectTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      name: "Alexander",
      email: "alex@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "subject can be created with valid data" do
    subject = Subject.new(
      name: "Programming",
      user: @user
    )

    assert subject.valid?
  end

  test "subject must have a name" do
    subject = Subject.new(
      name: "",
      user: @user
    )

    assert_not subject.valid?
  end

  test "subject must belong to a user" do
    subject = Subject.new(
      name: "Programming"
    )

    assert_not subject.valid?
  end

  test "subject name must be unique for one user" do
    Subject.create!(
      name: "Programming",
      user: @user
    )

    second_subject = Subject.new(
      name: "Programming",
      user: @user
    )

    assert_not second_subject.valid?
  end

  test "different users can have subjects with same name" do
    second_user = User.create!(
      name: "Alexey",
      email: "alexey@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    Subject.create!(
      name: "Programming",
      user: @user
    )

    second_subject = Subject.new(
      name: "Programming",
      user: second_user
    )

    assert second_subject.valid?
  end
end