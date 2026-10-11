class HomeController < ApplicationController
  before_action :require_login

  def index
    @tasks_count = current_user.total_tasks_count
    @completed_tasks_count = current_user.completed_tasks_count

    @upcoming_tasks = current_user.tasks
                                  .includes(:subject)
                                  .where.not(status: "completed")
                                  .where("deadline >= ?", Date.current)
                                  .order(:deadline)
                                  .limit(5)

    @nearest_task = @upcoming_tasks.first
  end
end