class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authorize_visibility!, only: [:show]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]
  def index
    # 自分が作成した予定の一覧を表示
    # @events = current_user.events

    # 自分の予定と所属チームの予定を表示
    @events = Event.where(user_id: current_user.id)
             .or(Event.where(team_id: current_user.team_ids))
             .distinct

    # fullcalendarに対応
    respond_to do |format|
      format.html
      format.json do
        render json: @events.map { |e|
          {
            id: e.id,
            title: e.title,
            start: e.start_time.iso8601,
            end: e.end_time&.iso8601
          }
        }
      end
    end
  end

  def show
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.new(event_params)

    # 自分が所属していないチームの予定は作成不可
    if @event.team_id.present? && !current_user.team_ids.include?(@event.team_id)
      return head :forbidden
    end

    if @event.save
      redirect_to events_path, notice: "予定を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to events_path, notice: "予定を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "予定を削除しました"
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :title, 
      :description,
      :start_time,
      :end_time,
      :team_id
    )
  end

  # 予定作成者、同じチームメンバー用の権限(show)
  def authorize_visibility!
    return if @event.user == current_user

    if @event.team.present?
      unless @event.team.users.include?(current_user)
        head :forbidden
      end
    else
      head :forbidden
    end
  end

  # 予定作成者用の権限(edit、update、destroy)
  def authorize_owner!
    head :forbidden unless @event.user == current_user
  end

end
