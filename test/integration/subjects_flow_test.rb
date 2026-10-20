require "test_helper"

class SubjectsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Student",
      email: "subject_flow@example.com",
      password: "password123"
    )

    post login_path, params: {
      session: { email: @user.email, password: "password123" }
    }
    assert_redirected_to root_path
  end

  test "creating a subject saves it and displays it" do
    get subjects_path
    assert_response :success

    assert_difference "Subject.count", 1 do
      post subjects_path, params: {
        subject: { name: "Математика" }
      }
    end
    assert_redirected_to subjects_path

    subject = @user.subjects.find_by!(name: "Математика")
    assert_equal @user.id, subject.user_id

    follow_redirect!
    assert_response :success
    assert_select "body", text: /Математика/
  end

  test "deleting a subject also deletes its tasks" do
    subject = @user.subjects.create!(name: "Базы данных")
    task1 = subject.tasks.create!(title: "Лабораторная 1", deadline: Date.tomorrow)
    task2 = subject.tasks.create!(title: "Лабораторная 2", deadline: Date.tomorrow)

    assert_difference "Subject.count", -1 do
      assert_difference "Task.count", -2 do
        delete subject_path(subject)
      end
    end
    assert_redirected_to subjects_path
    assert_not Subject.exists?(subject.id)
    assert_not Task.exists?(task1.id)
    assert_not Task.exists?(task2.id)

    get tasks_path
    assert_response :success
    assert_select "tr", text: /Лабораторная [12]/, count: 0
  end

  test "same user cannot create two subjects with the same name" do
    @user.subjects.create!(name: "Программирование")

    assert_no_difference "Subject.count" do
      post subjects_path, params: {
        subject: { name: "Программирование" }
      }
    end
    assert_response :unprocessable_entity
    assert_select ".form-errors"
    assert_equal 1, @user.subjects.where(name: "Программирование").count
  end
end
