require 'rails_helper'

RSpec.describe "Events", type: :request do
  describe "GET /" do
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    context "ログインしている場合" do
      let(:user) { create(:user) }
      let(:event_params) do
        {
          event: {
            title: "自分が作成した予定",
            description: "新商材についての会議",
            start_time: Time.now,
            end_time: 1.hour.ago
          }
        }
      end
      before do
        sign_in user
      end
      it "トップページにアクセスできる" do
        get root_path
        expect(response).to have_http_status(:ok)
      end
      it "自分が作成した予定が表示される" do
        post events_path, params: event_params
        get root_path
        expect(response.body).to include("自分が作成した予定")
      end
    end
  end

  # describe "GET /show" do
  #   it "returns http success" do
  #     get "/events/show"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  describe "GET /new" do
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get new_event_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    context "ログインしている場合" do
      let(:user) { create(:user) }
      before do
        sign_in user
      end
      it "予定の新規登録画面にアクセスできる" do
        get new_event_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /events" do
    let(:user) { create(:user) }
    let(:team) { create(:team) }
    let(:user_event_params) do
      {
        event: {
          title: "会議",
          description: "新商材についての会議",
          team_id: nil
        }
      }
    end
    let(:team_event_params) do
      {
        event: {
          title: "会議",
          description: "新商材についての会議",
          team_id: team.id
        }
      }
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        post events_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
      end

      it "個人の予定を作成できる" do
        expect {
          post events_path, params: user_event_params
        }.to change(Event, :count).by(1)
      end
      it "チームの予定を作成できる" do
        expect {
          post events_path, params: team_event_params
        }.to change(Event, :count).by(1)
      end
      it "予定の作成者がログインユーザーになっている" do
        post events_path, params: user_event_params
        expect(Event.last.user).to eq(user)
      end
      it "予定を作成後、予定一覧ページに遷移する" do
      post events_path, params: user_event_params
      expect(response).to redirect_to(events_path)
      end
    end
  end

  # describe "GET /edit" do
  #   it "returns http success" do
  #     get "/events/edit"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe "GET /update" do
  #   it "returns http success" do
  #     get "/events/update"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe "GET /destroy" do
  #   it "returns http success" do
  #     get "/events/destroy"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end
