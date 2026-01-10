class EventsController < ApplicationController
  before_action :authenticate_user!
  def index

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
      render :new, status: unprocessable-entity
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
