class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_user, only: [:edit, :update, :destroy]
  def index
    @users = User.all
  end

  def new
    @user = User.new
    @teams = Team.all
  end

  def create
    @user = User.new(
      name: user_params[:name],
      email: user_params[:email]
    )

    @user.errors.add(:name, "ユーザー名を入力してください") if @user.name.blank?
    @user.errors.add(:email, "メールアドレスを入力してください") if @user.email.blank?

    if User.exists?(email: @user.email)
      @user.errors.add(:email, "このメールアドレスのユーザーはすでに存在します")
    end

    if @user.errors.empty?
      Rails.logger.error "=== DELIVERY: #{ActionMailer::Base.delivery_method}"
      Rails.logger.error "=== SMTP: #{ActionMailer::Base.smtp_settings.inspect}"
      Rails.logger.info "Default URL: #{ActionMailer::Base.default_url_options.inspect}"
      invited_user = User.invite!(
        name: user_params[:name],
        email: user_params[:email]
      )

      invited_user.update(
        admin: user_params[:admin],
        team_ids: user_params[:team_ids]
      )

      redirect_to admin_users_path,
                  notice: "新規ユーザーを招待しました"
    else
      @teams = Team.all
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @users = User.all
    @teams = Team.all
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "ユーザーを更新しました"
    else
      @teams = Team.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "ユーザーを削除しました"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    if action_name == "create"
      params.require(:user).permit(:name, :email, :admin, team_ids: [])
    else
      params.require(:user).permit(:name, :admin, team_ids: [])
    end
  end

  # 管理者権限
  def authorize_admin!
    redirect_to root_path, alert: "権限がありません" unless current_user.admin?
  end

end
