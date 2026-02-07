class EventsController < ApplicationController
  before_action :authenticate_user!
  def index
    # 自分が作成した予定の一覧を表示(今後、所属チームの予定の表示についても調整予定)
    @events = current_user.events
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
    if @event.save
      redirect_to events_path
    else
      render :new, status: unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def event_params
    params.require(:event).permit(
      :title, 
      :description,
      :start_time,
      :end_time,
      :team_id
    )
  end

end
