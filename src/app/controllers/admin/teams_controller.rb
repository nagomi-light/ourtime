class Admin::TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_team, only: [:edit, :update, :destroy]
  def index
    @teams = Team.all
  end

  def new
    @team = Team.new
    @users = User.all
  end

  def create
    @team = Team.new(team_params)

    if @team.save
      redirect_to admin_teams_path, notice: "チームを作成しました"
    else
      @users = User.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.all
  end

  def update
    if @team.update(team_params)
      redirect_to admin_teams_path, notice: "チームを更新しました"
    else
      @users = User.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team.destroy
    redirect_to admin_teams_path, notice: "予定を削除しました"
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(
      :name, 
      user_ids: []
    )
  end

  # 管理者権限
  def authorize_admin!
    redirect_to root_path, alert: "権限がありません" unless current_user.admin?
  end

  
end
