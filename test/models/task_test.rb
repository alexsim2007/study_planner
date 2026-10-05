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

  test "completed? returns true for completed task" do
    task = Task.new(
      status: "completed"
    )

    assert task.completed?
  end

  test "completed? returns false for unfinished task" do
    task = Task.new(
      status: "pending"
    )

    assert_not task.completed?
  end

  test "overdue? returns true for unfinished task with past deadline" do
    task = Task.new(
      status: "pending",
      deadline: Date.yesterday
    )

    assert task.overdue?
  end

  test "overdue? returns false for completed task" do
    task = Task.new(
      status: "completed",
      deadline: Date.yesterday
    )

    assert_not task.overdue?
  end

  test "overdue? returns false for future deadline" do
    task = Task.new(
      status: "pending",
      deadline: Date.tomorrow
    )

    assert_not task.overdue?
  end

  test "days_left returns number of days until deadline" do
    task = Task.new(
      deadline: Date.current + 5.days
    )

    assert_equal 5, task.days_left
  end

  test "days_left returns nil without deadline" do
    task = Task.new

    assert_nil task.days_left
  end

end