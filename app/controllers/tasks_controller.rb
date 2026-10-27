class TasksController < ApplicationController
  before_action :require_login

  def index
  end

  def new
    @task = Task.new
    @subjects = current_user.subjects.order(:name)
  end

  def create
    subject = current_user.subjects.find(task_params[:subject_id]) if task_params[:subject_id].present?

    @task = Task.new(task_params.except(:subject_id))
    @task.subject = subject

    if @task.save
      redirect_to tasks_path, notice: "Задание добавлено.", status: :see_other
    else
      @subjects = current_user.subjects.order(:name)

      render :new, formats: [ :html ], status: :unprocessable_entity
    end
  end

  def complete
    task = current_user.tasks.find(params[:id])

    task.update!(status: "completed")

    respond_with_updates("Задание выполнено.")
  end

  def destroy
    task = current_user.tasks.find(params[:id])

    task.destroy!

    respond_with_updates("Задание удалено.")
  end

  private

  def respond_with_updates(message)
    respond_to do |format|
      format.turbo_stream { render :update, locals: { message: message } }
      format.html { redirect_to tasks_path, notice: message, status: :see_other }
    end
  end

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
