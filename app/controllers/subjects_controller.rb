class SubjectsController < ApplicationController
  before_action :require_login

  def index
    @subject = Subject.new
  end

  def create
    @subject = current_user.subjects.new(subject_params)

    if @subject.save
      respond_with_updates("Предмет добавлен.", reset_form: true)
    else
      render :index, formats: [ :html ], status: :unprocessable_entity
    end
  end

  def destroy
    subject = current_user.subjects.find(params[:id])
    subject.destroy!

    respond_with_updates("Предмет удалён.")
  end

  private

  def respond_with_updates(message, reset_form: false)
    respond_to do |format|
      format.turbo_stream { render :update, locals: { message: message, reset_form: reset_form } }
      format.html { redirect_to subjects_path, notice: message, status: :see_other }
    end
  end

  def subject_params
    params.require(:subject).permit(:name)
  end
end
