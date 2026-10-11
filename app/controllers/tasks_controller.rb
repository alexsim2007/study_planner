class TasksController < ApplicationController
  before_action :require_login

  def index
    @tasks = current_user.tasks
                         .includes(:subject)
                         .order(:deadline)
  end

  def new
    @task = Task.new
    @subjects = current_user.subjects.order(:name)
  end

  def create
    subject = current_user.subjects.find(task_params[:subject_id])

    @task = subject.tasks.new(
      task_params.except(:subject_id)
    )

    if @task.save
      redirect_to tasks_path, notice: "Задание добавлено."
    else
      @subjects = current_user.subjects.order(:name)

      render :new, status: :unprocessable_entity
    end
  end

  def complete
    task = current_user.tasks.find(params[:id])

    task.update!(status: "completed")

    redirect_to tasks_path, notice: "Задание выполнено."
  end

  def destroy
    task = current_user.tasks.find(params[:id])

    task.destroy

    redirect_to tasks_path, notice: "Задание удалено."
  end

  private

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :deadline,
      :status,
      :priority,
      :subject_id
    )
  end
end