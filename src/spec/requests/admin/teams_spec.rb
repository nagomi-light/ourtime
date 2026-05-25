require 'rails_helper'

RSpec.describe "Admin::Teams", type: :request do 
  describe "GET /admin/teams" do
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get admin_teams_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "一般ユーザーがログインしている場合" do
      let(:user) do
        create(:user, admin: false)
      end
      before do
        sign_in user
      end
      it "ホーム画面にリダイレクトされる" do
        get admin_teams_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "管理者がログインしている場合" do
      let(:admin) do
        create(:user, admin: true)
      end
      let!(:team_a) { create(:team, name: "チームA", owner_id: admin.id) }
      let!(:team_b) { create(:team, name: "チームB", owner_id: admin.id) }
      before do
        sign_in admin
      end
      it "チーム管理ページにアクセスできる" do
        get admin_teams_path
        expect(response).to have_http_status(:ok)
      end
      it "チームの一覧が表示される" do
        get admin_teams_path
        expect(response.body).to include("チームA")
        expect(response.body).to include("チームB")
      end
    end
  end

  describe "GET /admin/teams/new" do
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get new_admin_team_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "一般ユーザーがログインしている場合" do
      let(:user) do
        create(:user, admin: false)
      end
      before do
        sign_in user
      end
      it "ホーム画面にリダイレクトされる" do
        get new_admin_team_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "管理者がログインしている場合" do
      let(:admin) do
        create(:user, admin: true)
      end
      before do
        sign_in admin
      end
      it "新規チームの作成画面にアクセスできる" do
        get new_admin_team_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /admin/teams" do
    context "ログインしていない場合" do
      let(:team_params) do
        {
          team: {
            name: "新規チーム"
          }
        }
      end
      it "新規チームは作成されず、ログインページにリダイレクトされる" do
        # チーム数の確認
        expect {
          post admin_teams_path, params: team_params
        }.not_to change(Team, :count)
        # リダイレクトの確認
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "一般ユーザーがログインしている場合" do
      let(:user) do
        create(:user, admin: false)
      end
      let(:team_params) do
        {
          team: {
            name: "新規チーム",
            user_ids: [user.id]
          }
        }
      end
      before do
        sign_in user
      end
      it "新規チームは作成されず、ホーム画面にリダイレクトされる" do
        # チーム数の確認
        expect {
          post admin_teams_path, params: team_params
        }.not_to change(Team, :count)
        # リダイレクトの確認
        expect(response).to redirect_to(root_path)
      end
    end

    context "管理者がログインしている場合" do
      let(:admin) do
        create(:user, admin: true)
      end
      let(:user_a) do
        create(:user, admin: false)
      end
      let(:user_b) do
        create(:user, admin: false)
      end
      let(:team_params) do
        {
          team: {
            name: "新規チーム",
            user_ids: [admin.id, user_b.id]
          }
        }
      end
      before do
        sign_in admin
      end
      it "新規チームを作成できる" do
        # チーム数の確認
        expect {
          post admin_teams_path, params: team_params
        }.to change(Team, :count).by(1)
        # チームメンバーの確認
        expect(Team.last.users).to include(admin)
        expect(Team.last.users).not_to include(user_a)
        expect(Team.last.users).to include(user_b)
      end
      it "新規チームの作成者が管理者になっている" do
        post admin_teams_path, params: team_params
        expect(Team.last.owner).to eq(admin)
      end
      it "新規チームを作成後、チーム管理ページに遷移する" do
      post admin_teams_path, params: team_params
      expect(response).to redirect_to(admin_teams_path)
      end
      
    end
  end

  describe "GET /edit" do
    # it "returns http success" do
    #   get "/admin/teams/edit"
    #   expect(response).to have_http_status(:success)
    # end
  end

  describe "GET /destroy" do

  end

end


