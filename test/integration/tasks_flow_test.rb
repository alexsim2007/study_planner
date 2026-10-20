require "test_helper"

class TasksFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Student",
      email: "task_flow@example.com",
      password: "password123"
    )
    @subject = @user.subjects.create!(name: "Программирование")

    post login_path, params: {
      session: { email: @user.email, password: "password123" }
    }
    assert_redirected_to root_path
  end

  test "task is created and linked to selected subject" do
    get new_task_path
    assert_response :success
    assert_select "select[name='task[subject_id]'] option", text: "Программирование"

    assert_difference "Task.count", 1 do
      post tasks_path, params: {
        task: {
          title: "Написать программу",
          description: "Лабораторная работа",
          deadline: Date.tomorrow.iso8601,
          status: "in_progress",
          priority: "medium",
          subject_id: @subject.id
        }
      }
    end
    assert_redirected_to tasks_path

    task = @user.tasks.find_by!(title: "Написать программу")
    assert_equal @subject.id, task.subject_id
    assert_equal "in_progress", task.status

    follow_redirect!
    assert_response :success
    assert_select "tr", text: /Написать программу.*Программирование/m
  end

  test "completing task changes status and dashboard counter" do
    task = @subject.tasks.create!(
      title: "Завершить лабораторную",
      deadline: Date.tomorrow,
      status: "pending"
    )

    get root_path
    assert_response :success
    assert_equal 0, @user.completed_tasks_count

    patch complete_task_path(task)
    assert_redirected_to tasks_path
    assert_equal "completed", task.reload.status

    get tasks_path
    assert_response :success
    assert_select "tr", text: /Завершить лабораторную.*Выполнено/m

    get root_path
    assert_response :success
    assert_equal 1, @user.completed_tasks_count
    assert_select ".stat-card__value", text: /\A\s*1\s*\z/, minimum: 2
  end

  test "dashboard shows real counts and upcoming tasks" do
    @subject.tasks.create!(
      title: "Ближайшая лабораторная",
      deadline: Date.tomorrow,
      status: "pending"
    )
    @subject.tasks.create!(
      title: "Уже выполненная работа",
      deadline: Date.current + 4.days,
      status: "completed"
    )

    get root_path
    assert_response :success
    assert_equal 2, @user.total_tasks_count
    assert_equal 1, @user.completed_tasks_count

    assert_select ".stat-card__value", text: /\A\s*2\s*\z/
    assert_select ".stat-card__value", text: /\A\s*1\s*\z/
    assert_select ".dashboard-task", text: /Ближайшая лабораторная/
    assert_select ".dashboard-task", text: /Уже выполненная работа/, count: 0
    nearest_date = Regexp.escape(Date.tomorrow.strftime("%d.%m"))
    assert_select ".stat-card__value", text: /\A\s*#{nearest_date}\s*\z/
  end

  test "invalid task data is rejected and errors are displayed" do
    assert_no_difference "Task.count" do
      post tasks_path, params: {
        task: {
          title: "",
          deadline: Date.tomorrow.iso8601,
          subject_id: @subject.id
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select ".form-errors", text: /Название.*не может быть пустым/

    assert_no_difference "Task.count" do
      post tasks_path, params: {
        task: {
          title: "Задание из прошлого",
          deadline: Date.yesterday.iso8601,
          subject_id: @subject.id
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select ".form-errors", text: /Дедлайн.*не может быть в прошлом/
  end
end
