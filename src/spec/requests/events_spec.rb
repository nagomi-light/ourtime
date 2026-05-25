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
            start_time: Time.zone.now,
            end_time: 1.hour.from_now
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
        get root_path(format: :json)
        json = JSON.parse(response.body)

        titles = json.map { |e| e["title"] }
        expect(titles).to include("自分が作成した予定")
      end
    end
  end

  describe "GET /show" do
    let(:user) { create(:user) }
    let(:event) { create(:event, title: "最初の予定", user: user) }


    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get event_path(event)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
      end
      it "予定の詳細画面にアクセスできる" do
        get event_path(event)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("最初の予定")
      end    
    end
  end

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
          team_id: nil,
          start_time: Time.zone.now,
          end_time: 1.hour.from_now
        }
      }
    end
    let(:team_event_params) do
      {
        event: {
          title: "会議",
          description: "新商材についての会議",
          team_id: team.id,
          start_time: Time.zone.now,
          end_time: 1.hour.from_now
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

  describe "GET /edit" do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let(:event_a) { create(:event, title: "ユーザーAの予定", user: user_a) }
    let(:event_b) { create(:event, title: "ユーザーBの予定", user: user_b) }
    
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get edit_event_path(event_a)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ユーザーAがログインしている場合" do
      before do
        sign_in user_a
      end
      it "ユーザーA(本人)の予定の編集画面にアクセスできる" do
        get edit_event_path(event_a)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("ユーザーAの予定")
      end
      # 追加テスト
      it "ユーザーB（別ユーザー）の予定の編集画面にアクセスできない" do
        get edit_event_path(event_b)
        expect(response).to have_http_status(:forbidden)
      end

    end
  end

  describe "PATCH /update" do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let(:event_a) { create(:event, title: "ユーザーAの変更前の予定", user: user_a) }
    let(:event_b) { create(:event, title: "ユーザーBの変更前の予定", user: user_b) }
    let(:event_params_update) do
      {
        event: {
          title: "変更後の予定"
        }
      }
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        patch event_path(event_a)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ユーザーAがログインしている場合" do
      before do
        sign_in user_a
      end
      it "ユーザーA(本人)の予定は更新できる" do
        patch event_path(event_a), params: event_params_update
        expect(event_a.reload.title).to eq("変更後の予定")
      end
      it "予定を更新した後、予定一覧ページに遷移する" do
        patch event_path(event_a), params: event_params_update
        expect(response).to redirect_to(events_path)
      end
      
      # 追加テスト
      it "ユーザーB（別ユーザー）の予定は更新できない" do
        patch event_path(event_b), params: event_params_update
        expect(response).to have_http_status(:forbidden)
        expect(event_b.reload.title).to eq("ユーザーBの変更前の予定")
      end

    end
  end

  describe "DELETE /destroy" do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let!(:event_a) { create(:event, title: "ユーザーAの予定", user: user_a) }
    let!(:event_b) { create(:event, title: "ユーザーBの予定", user: user_b) }
    
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        delete event_path(event_a)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ユーザーAがログインしている場合" do
      before do
        sign_in user_a
      end
      it "ユーザーA(本人)の予定を削除できる" do
        expect {
          delete event_path(event_a)
        }.to change(Event, :count).by(-1)
      end
      it "予定を削除後、予定一覧ページに遷移する" do
        delete event_path(event_a)
        expect(response).to redirect_to(events_path)
      end
      
      # 追加テスト
      it "ユーザーB（別ユーザー）の予定は削除できない" do
        expect {
          delete event_path(event_b)
        }.to change(Event, :count).by(0)
        expect(response).to have_http_status(:forbidden)
      end

    end
  end

end
