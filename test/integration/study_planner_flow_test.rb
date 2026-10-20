require "test_helper"

class StudyPlannerFlowTest < ActionDispatch::IntegrationTest
  test "happy path: register, create subject and task, complete and delete" do
    # Регистрация одновременно авторизует пользователя.
    get register_path
    assert_response :success

    assert_difference "User.count", 1 do
      post register_path, params: {
        user: {
          name: "Alexander",
          email: "happy_path@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_path
    user = User.find_by!(email: "happy_path@example.com")

    # Создание предмета через настоящий HTTP-запрос.
    assert_difference "Subject.count", 1 do
      post subjects_path, params: {
        subject: { name: "Базы данных" }
      }
    end
    assert_redirected_to subjects_path
    subject = user.subjects.find_by!(name: "Базы данных")

    follow_redirect!
    assert_response :success
    assert_select "body", text: /Базы данных/

    # В форме создания задания должен быть созданный предмет.
    get new_task_path
    assert_response :success
    assert_select "select[name='task[subject_id]'] option", text: "Базы данных"

    assert_difference "Task.count", 1 do
      post tasks_path, params: {
        task: {
          title: "Лабораторная №5",
          description: "Написать SQL-запросы",
          deadline: (Date.current + 3.days).iso8601,
          status: "pending",
          priority: "high",
          subject_id: subject.id
        }
      }
    end
    assert_redirected_to tasks_path

    task = subject.tasks.find_by!(title: "Лабораторная №5")
    assert_equal "pending", task.status
    assert_equal "high", task.priority

    follow_redirect!
    assert_response :success
    assert_select "tr", text: /Лабораторная №5/

    # Задание отражается в предстоящих задачах на главной.
    get root_path
    assert_response :success
    assert_select "body", text: /Лабораторная №5/

    # После выхода и нового входа данные сохранились.
    delete logout_path
    assert_redirected_to login_path
    get tasks_path
    assert_redirected_to login_path

    post login_path, params: {
      session: { email: user.email, password: "password123" }
    }
    assert_redirected_to root_path

    get tasks_path
    assert_response :success
    assert_select "tr", text: /Лабораторная №5/

    # Завершение задания.
    patch complete_task_path(task)
    assert_redirected_to tasks_path
    assert task.reload.completed?
    assert_equal 1, user.completed_tasks_count

    get tasks_path
    assert_response :success
    assert_select "tr", text: /Лабораторная №5.*Выполнено/m

    # Задание удаляется, а затем удаляется его предмет.
    assert_difference "Task.count", -1 do
      delete task_path(task)
    end
    assert_redirected_to tasks_path

    follow_redirect!
    assert_select "tr", text: /Лабораторная №5/, count: 0

    assert_difference "Subject.count", -1 do
      delete subject_path(subject)
    end
    assert_redirected_to subjects_path
    assert_not Subject.exists?(subject.id)
  end
end
