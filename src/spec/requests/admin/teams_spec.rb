require 'rails_helper'

RSpec.describe "Admin::Teams", type: :request do 
  describe "/admin/teams/index" do
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

  describe "/admin/teams/new" do
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

  describe "GET /create" do
    # it "returns http success" do
    #   get "/admin/teams/create"
    #   expect(response).to have_http_status(:success)
    # end
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


