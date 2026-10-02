require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    user = User.create!(
      name: "Alexander",
      email: "alex@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @subject = Subject.create!(
      name: "Programming",
      user: user
    )
  end

  test "task can be created with valid data" do
    task = Task.new(
      title: "Laboratory work",
      description: "Complete the Rails task",
      deadline: Date.tomorrow,
      status: "pending",
      priority: "medium",
      subject: @subject
    )

    assert task.valid?
  end

  test "task must have a title" do
    task = Task.new(
      title: "",
      deadline: Date.tomorrow,
      status: "pending",
      priority: "medium",
      subject: @subject
    )

    assert_not task.valid?
  end

  test "task must have a deadline" do
    task = Task.new(
      title: "Laboratory work",
      status: "pending",
      priority: "medium",
      subject: @subject
    )

    assert_not task.valid?
  end

  test "task must belong to a subject" do
    task = Task.new(
      title: "Laboratory work",
      deadline: Date.tomorrow,
      status: "pending",
      priority: "medium"
    )

    assert_not task.valid?
  end

  test "task status must be valid" do
    task = Task.new(
      title: "Laboratory work",
      deadline: Date.tomorrow,
      status: "wrong_status",
      priority: "medium",
      subject: @subject
    )

    assert_not task.valid?
  end

  test "task priority must be valid" do
    task = Task.new(
      title: "Laboratory work",
      deadline: Date.tomorrow,
      status: "pending",
      priority: "wrong_priority",
      subject: @subject
    )

    assert_not task.valid?
  end

  test "new task has default status and priority" do
    task = Task.create!(
      title: "Laboratory work",
      deadline: Date.tomorrow,
      subject: @subject
    )

    assert_equal "pending", task.status
    assert_equal "medium", task.priority
  end
end