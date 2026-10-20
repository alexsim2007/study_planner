require "test_helper"

class AccessControlTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(
      name: "Owner",
      email: "access_owner@example.com",
      password: "password123"
    )
    @intruder = User.create!(
      name: "Other User",
      email: "access_intruder@example.com",
      password: "password123"
    )

    @owners_subject = @owner.subjects.create!(name: "Секретный предмет")
    @owners_task = @owners_subject.tasks.create!(
      title: "Чужая лабораторная",
      deadline: Date.tomorrow,
      status: "pending"
    )

    # Авторизуемся не владельцем, а другим пользователем.
    post login_path, params: {
      session: { email: @intruder.email, password: "password123" }
    }
    assert_redirected_to root_path
  end

  test "user cannot see, complete or delete another user's task" do
    get tasks_path
    assert_response :success
    assert_select "tr", text: /Чужая лабораторная/, count: 0

    patch complete_task_path(@owners_task)
    assert_response :not_found
    assert_equal "pending", @owners_task.reload.status

    assert_no_difference "Task.count" do
      delete task_path(@owners_task)
    end
    assert_response :not_found
    assert Task.exists?(@owners_task.id)
  end

  test "user cannot delete another user's subject or create task in it" do
    get subjects_path
    assert_response :success
    assert_select "body", text: /Секретный предмет/, count: 0

    assert_no_difference "Task.count" do
      post tasks_path, params: {
        task: {
          title: "Подставлен чужой ID",
          deadline: Date.tomorrow.iso8601,
          status: "pending",
          priority: "medium",
          subject_id: @owners_subject.id
        }
      }
    end
    assert_response :not_found

    assert_no_difference "Subject.count" do
      delete subject_path(@owners_subject)
    end
    assert_response :not_found
    assert Subject.exists?(@owners_subject.id)
  end
end
