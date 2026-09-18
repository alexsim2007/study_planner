class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:session][:email].to_s.strip.downcase
    password = params[:session][:password].to_s

    user = User.find_by(email: email)

    if user&.authenticate(password)
      reset_session
      session[:user_id] = user.id

      redirect_to root_path, notice: "Вы вошли в аккаунт!"
    else
      flash.now[:alert] = "Неверный email или пароль."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Вы вышли из аккаунта."
  end
end