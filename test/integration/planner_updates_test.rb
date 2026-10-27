require "test_helper"

class PlannerUpdatesTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  setup do
    @user = User.create!(name: "Student", email: "planner@example.com", password: "password123")
    @subject = @user.subjects.create!(name: "Математика")
    @task = @subject.tasks.create!(title: "Контрольная", deadline: Date.current)
    @stream = Turbo::StreamsChannel.send(:stream_name_from, [ @user, :planner ])
    post login_path, params: { session: { email: @user.email, password: "password123" } }
  end

  test "ordinary pages subscribe to a private stream and render update frames" do
    { root_path => %w[dashboard_statistics dashboard_upcoming],
      tasks_path => %w[tasks_list], subjects_path => %w[subject_form subjects_list],
      profile_path => %w[profile_statistics] }.each do |path, frames|
      get path
      assert_response :success
      frames.each { |id| assert_select "turbo-frame##{id}" }
      assert_select "turbo-cable-stream-source" do |sources|
        assert_equal 1, sources.size
        signed_name = sources.first["signed-stream-name"]
        assert_equal @stream, Turbo::StreamsChannel.verified_stream_name(signed_name)
      end
      assert_select "a", text: "LIVE", count: 0
    end

    get live_path
    assert_redirected_to root_path
  end

  test "completion responds with partial HTML and broadcasts current data only to the owner" do
    other_user = User.create!(name: "Other", email: "other-planner@example.com", password: "password123")
    other_stream = Turbo::StreamsChannel.send(:stream_name_from, [ other_user, :planner ])
    messages = nil
    assert_no_broadcasts other_stream do
      messages = capture_broadcasts(@stream) do
        patch complete_task_path(@task), headers: turbo_headers
      end
    end
    assert_response :success
    assert @task.reload.completed?
    assert_equal 1, messages.size
    assert_updates Nokogiri::HTML.fragment(messages.last)
    assert_updates Nokogiri::HTML.fragment(response.body)
    assert_select 'turbo-stream[target="dashboard_statistics"] .stat-card__value', text: /\A\s*1\s*\z/, count: 2
    assert_select 'turbo-stream[target="dashboard_upcoming"] .dashboard-task', count: 0
    assert_select 'turbo-stream[target="subjects_list"] .progress__text strong', text: /100%/
    assert_select 'turbo-stream[target="flash_messages"]', text: /Задание выполнено/
  end

  test "creation and deletion broadcast and empty the ordinary lists" do
    messages = capture_broadcasts(@stream) do
      post tasks_path, params: { task: { title: "Новая задача", deadline: Date.tomorrow, subject_id: @subject.id } }
    end
    assert_redirected_to tasks_path
    assert_equal 1, messages.size
    assert_includes messages.last, "Новая задача"

    messages = capture_broadcasts(@stream) do
      delete subject_path(@subject), headers: turbo_headers
    end
    assert_response :success
    assert_not Task.exists?(@task.id)
    assert_updates Nokogiri::HTML.fragment(messages.last)
    assert_select 'turbo-stream[target="tasks_list"]', text: /Заданий пока нет/
    assert_select 'turbo-stream[target="subjects_list"]', text: /Предметов пока нет/
    assert_select 'turbo-stream[target="dashboard_statistics"] .stat-card__value', text: /\A\s*0\s*\z/, count: 2
  end

  test "task deletion returns partial updates" do
    assert_difference "Task.count", -1 do
      delete task_path(@task), headers: turbo_headers
    end
    assert_response :success
    assert_updates Nokogiri::HTML.fragment(response.body)
    assert_select 'turbo-stream[target="tasks_list"]', text: /Заданий пока нет/
  end

  test "subject creation resets only its form and validation preserves errors" do
    post subjects_path, params: { subject: { name: "Физика" } }, headers: turbo_headers
    assert_response :success
    assert_select 'turbo-stream[target="subject_form"] input[name="subject[name]"][value]', count: 0
    assert_select 'turbo-stream[target="subjects_list"]', text: /Физика/

    assert_no_broadcasts @stream do
      post subjects_path, params: { subject: { name: "Физика" } }, headers: turbo_headers.merge("Turbo-Frame" => "subject_form")
    end
    assert_response :unprocessable_entity
    assert_select "turbo-frame#subject_form .form-errors", text: /уже существует/
    assert_select 'input[name="subject[name]"][value="Физика"]'
  end

  test "blank subject is a validation error and today's deadline is allowed" do
    post tasks_path, params: { task: { title: "Черновик", deadline: Date.current, subject_id: "" } }, headers: turbo_headers
    assert_response :unprocessable_entity
    assert_select ".form-errors", text: /Предмет должен быть выбран/
    assert_select 'input[name="task[title]"][value="Черновик"]'

    post tasks_path, params: { task: { title: "На сегодня", deadline: Date.current, subject_id: @subject.id } }, headers: turbo_headers
    assert_redirected_to tasks_path
    assert @subject.tasks.exists?(title: "На сегодня")
  end

  test "an overdue task can be completed without changing its deadline" do
    @task.update_column(:deadline, Date.yesterday)
    patch complete_task_path(@task), headers: turbo_headers
    assert_response :success
    assert @task.reload.completed?
    assert_equal Date.yesterday, @task.deadline
  end

  test "profile displays actual totals" do
    get profile_path
    assert_select "#profile_statistics strong", text: "1", count: 2
    assert_select "#profile_statistics strong", text: "0", count: 1
  end

  private

  def turbo_headers
    { "Accept" => "text/vnd.turbo-stream.html" }
  end

  def assert_updates(document)
    %w[dashboard_statistics dashboard_upcoming tasks_list subjects_list profile_statistics].each do |target|
      assert_equal 1, document.css("turbo-stream[action='replace'][target='#{target}'] turbo-frame##{target}").size
    end
    assert_empty document.css("turbo-stream[action='refresh']")
  end
end
