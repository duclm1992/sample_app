class UsersController < ApplicationController
  before_action :logged_in_user, except: [:new, :create]
  before_action :admin_user, only: :destroy
  before_action :find_user, except: [:index, :new, :create]
  before_action :correct_user, only: [:edit, :update]

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @user = User.find_by id: params[:id]
    redirect_to root_path and return false unless @user.activated?
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted!"
    redirect_to users_url
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def find_user
    @user = User.find_by id: params[:id]
    unless @user
      flash[:danger] = "User not found!"
      redirect_to root_path
    end
  end

  def correct_user
    redirect_to root_path unless current_user.current_user? @user
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
