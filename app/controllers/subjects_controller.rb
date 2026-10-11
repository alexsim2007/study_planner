class SubjectsController < ApplicationController
  before_action :require_login

  def index
    @subjects = current_user.subjects.order(:name)
    @subject = Subject.new
  end

  def create
    @subject = current_user.subjects.new(subject_params)

    if @subject.save
      redirect_to subjects_path, notice: "Предмет добавлен."
    else
      @subjects = current_user.subjects.order(:name)

      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    subject = current_user.subjects.find(params[:id])
    subject.destroy

    redirect_to subjects_path, notice: "Предмет удалён."
  end

  private

  def subject_params
    params.require(:subject).permit(:name)
  end
end