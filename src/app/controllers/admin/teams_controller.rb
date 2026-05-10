class Admin::TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  def index
    @teams = Team.all
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  # 管理者権限
  def authorize_admin!
    redirect_to root_path, alert: "権限がありません" unless current_user.admin?
  end
end
