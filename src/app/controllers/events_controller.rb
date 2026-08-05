class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authorize_visibility!, only: [:show]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]
  before_action :normalize_all_day_times, only: [:create, :update]
  
  def index
    # 所属チームを表示
    @teams = current_user.teams

    # 自分の予定と所属チームの予定を表示
    @events = Event.where(user_id: current_user.id)
             .or(Event.where(team_id: current_user.team_ids))
             .distinct

    # fullcalendarに対応
    respond_to do |format|
      format.html
      format.json do
        events = []
        range_start =
          params[:start].present? ?
            Time.zone.parse(params[:start]) :
            Time.zone.today.beginning_of_month
        range_end =
          params[:end].present? ?
            Time.zone.parse(params[:end]) :
            Time.zone.today.end_of_month

        @events.each do |event|
          if event.repeat_rule.present?
            schedule = IceCube::Schedule.from_yaml(event.repeat_rule)  

            occurrences = schedule.occurrences_between(
              range_start,
              range_end
            )

            occurrences.each do |occurrence|
              events << {
                id: event.id,
                title: event.title,
                start: occurrence.iso8601,
                end: (occurrence + (event.end_time - event.start_time)).iso8601,
                team_id: event.team_id,
                user_id: event.user_id,
                allDay: event.all_day,
                color: event.calendar_color
              }
            end
          else
            events << {
              id: event.id,
              title: event.title,
              start: event.start_time.iso8601,
              end: event.end_time&.iso8601,
              team_id: event.team_id,
              user_id: event.user_id,
              allDay: event.all_day,
              color: event.calendar_color
            }
          end
        end

        render json: events
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
    set_repeat_rule

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
    @event.assign_attributes(event_params)
    set_repeat_rule

    if @event.save
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
      :all_day,
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

  # 終日予定の設定
  def normalize_all_day_times
    return unless params[:event][:all_day] == "1"

    start_date = Date.parse(params[:event][:start_time])
    end_date   = Date.parse(params[:event][:end_time])

    params[:event][:start_time] = start_date.beginning_of_day
    params[:event][:end_time]   = end_date.next_day.beginning_of_day
  end

  # 繰り返し予定の設定
  def set_repeat_rule
    case params[:repeat_type]
    when nil, "none"
      @event.repeat_rule = nil
      return
    end

    schedule = IceCube::Schedule.new(@event.start_time)

    case params[:repeat_type]
    when "daily"
      schedule.add_recurrence_rule(IceCube::Rule.daily)
    when "weekly"
      schedule.add_recurrence_rule(IceCube::Rule.weekly)
    when "monthly"
      schedule.add_recurrence_rule(IceCube::Rule.monthly)
    when "yearly"
      schedule.add_recurrence_rule(IceCube::Rule.yearly)
    end

    @event.repeat_rule = schedule.to_yaml
  end

end
