require "rails_helper"

RSpec.describe "Team Events", type: :request do
  let(:my_team) { create(:team) }
  let(:other_team) { create(:team) }

  let(:user) { create(:user) }
  let(:teammate) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    # ログイン中のユーザー
    create(:team_member, team: my_team, user: user)

    # 自チームの他ユーザー
    create(:team_member, team: my_team, user: teammate)

    # 他チームのユーザー
    create(:team_member, team: other_team, user: other_user)
    sign_in user
  end

  describe "GET /" do 
    let!(:my_team_event) do
      create(:event,
        title: "自チームの予定",
        user: teammate,
        team: my_team,
        start_time: Time.zone.now,
        end_time: 1.hour.from_now
      )
    end

    let!(:other_team_event) do
      create(:event,
        title: "他チームの予定",
        user: other_user,
        team: other_team,
        start_time: Time.zone.now,
        end_time: 1.hour.from_now
      )
    end

    it "所属しているチームの予定が表示される" do
        get root_path(format: :json)
        json = JSON.parse(response.body)

        titles = json.map { |e| e["title"] }
        expect(titles).to include("自チームの予定")
    end
    it "所属していないチームの予定は表示されない" do
        get root_path(format: :json)
        json = JSON.parse(response.body)

        titles = json.map { |e| e["title"] }
        expect(titles).not_to include("他チームの予定")
    end
  end

  describe "GET /show" do
    let!(:my_team_event) do
      create(:event,
        user: teammate,
        team: my_team,
        start_time: Time.zone.now,
        end_time: 1.hour.from_now
      )
    end

    let!(:other_team_event) do
      create(:event,
        user: other_user,
        team: other_team,
        start_time: Time.zone.now,
        end_time: 1.hour.from_now
      )
    end

    it "所属しているチームの予定の詳細画面にアクセスできる" do
      get event_path(my_team_event)
      expect(response).to have_http_status(:ok)
    end

    it "他チームの予定の詳細画面にアクセスできない" do
      get event_path(other_team_event)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /events" do
    let(:my_team_event_params) do
      {
        event: {
          title: "自チームの予定",
          description: "作成できるはず",
          team_id: my_team.id,
          start_time: Time.zone.now,
          end_time: 1.hour.from_now
        }
      }
    end
    let(:other_team_event_params) do
      {
        event: {
          title: "他チームの予定",
          description: "作成できないはず",
          team_id: other_team.id,
          start_time: Time.zone.now,
          end_time: 1.hour.from_now
        }
      }
    end

      it "自チームの予定は作成できる" do
        expect {
          post events_path, params: my_team_event_params
        }.to change(Event, :count).by(1)
      end

      it "他チームの予定は作成できない" do
        expect {
          post events_path, params: other_team_event_params
        }.to change(Event, :count).by(0)
        expect(response).to have_http_status(:forbidden)
      end
  end

  describe "GET /edit" do
    # 他ユーザーが作成した自チームの予定
    let!(:my_team_event) do
      create(:event,
        title: "編集したい予定",
        user: teammate,
        team: my_team,
        start_time: Time.zone.now,
        end_time: 1.hour.from_now
      )
    end

    it "自チームの予定であっても、予定作成者でなければ編集画面にアクセスできない" do
      get edit_event_path(my_team_event)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /update" do
    # 他ユーザーが作成した自チームの予定
    let!(:my_team_event) do
      create(:event,
        title: "更新したい予定",
        user: teammate,
        team: my_team,
        start_time: Time.zone.now,
        end_time: 1.hour.from_now
      )
    end

    it "自チームの予定であっても、予定作成者でなければ更新できない" do
      patch event_path(my_team_event),
          params: { event: { title: "変更後の予定" } }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /destroy" do  
    # 他ユーザーが作成した自チームの予定
    let!(:my_team_event) do
      create(:event,
        title: "削除したい予定",
        user: teammate,
        team: my_team,
        start_time: Time.zone.now,
        end_time: 1.hour.from_now
      )
    end

    it "自チームの予定であっても、予定作成者でなければ削除できない" do
      expect {
          delete event_path(my_team_event)
        }.to change(Event, :count).by(0)
      expect(response).to have_http_status(:forbidden)
    end
  end

end