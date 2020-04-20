# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: [:destroy, :edit, :update]

  # GET /users
  def index
    authorize User
    @users = User.all.page(params[:page])
  end

  # GET /users/new
  def new
    authorize User
    @user = User.new
    @roles = Role.all
  end

  # POST /users
  def create
    authorize @user
    @user = User.new(user_params.except(:roles))
    @user.user_roles = user_roles_from_params

    @user.invited = DateTime.now
    if @user.save
      UserSignInMailer.send_invite_email(@user, root_url).deliver
      redirect_to :users, notice: 'User was successfully created.'
    else
      @roles = Role.all
      render :new
    end
  end

  def edit
    authorize @user
    @roles = Role.all
  end

  def update
    authorize @user
    @user.roles = user_roles_from_params
    @user.assign_attributes(user_params.except(:roles))

    if @user.save
      redirect_to :users, notice: 'User was successfully updated.'
    else
      @roles = Role.all
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    authorize @user
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

  def user_roles_from_params
    return [] if user_params[:roles].nil?
    Role.find(user_params[:roles])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :admin, :first_name, :last_name, :roles => [])
  end
end
