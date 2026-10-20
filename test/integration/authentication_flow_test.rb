require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  test "registration, logout and login work through HTTP" do
    get register_path
    assert_response :success

    assert_difference "User.count", 1 do
      post register_path, params: {
        user: {
          name: "Test Student",
          email: "auth_flow@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_path

    get root_path
    assert_response :success

    delete logout_path
    assert_redirected_to login_path

    get root_path
    assert_redirected_to login_path

    post login_path, params: {
      session: {
        email: "auth_flow@example.com",
        password: "password123"
      }
    }
    assert_redirected_to root_path

    get tasks_path
    assert_response :success
  end

  test "guest cannot view, create or change protected resources" do
    get subjects_path
    assert_redirected_to login_path

    get tasks_path
    assert_redirected_to login_path

    get new_task_path
    assert_redirected_to login_path

    assert_no_difference "Subject.count" do
      post subjects_path, params: {
        subject: { name: "Без авторизации" }
      }
    end
    assert_redirected_to login_path

    assert_no_difference "Task.count" do
      post tasks_path, params: {
        task: { title: "Без авторизации" }
      }
    end
    assert_redirected_to login_path

    owner = User.create!(
      name: "Owner",
      email: "guest_check_owner@example.com",
      password: "password123"
    )
    subject = owner.subjects.create!(name: "Программирование")
    task = subject.tasks.create!(
      title: "Задача владельца",
      deadline: Date.tomorrow
    )

    patch complete_task_path(task)
    assert_redirected_to login_path
    assert_equal "pending", task.reload.status

    assert_no_difference "Task.count" do
      delete task_path(task)
    end
    assert_redirected_to login_path
    assert Task.exists?(task.id)
  end
end
