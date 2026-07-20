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
      let!(:team_a) { create(:team, name: "チームA") }
      let!(:team_b) { create(:team, name: "チームB") }
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
      it "新規チームは作成できず、ログインページにリダイレクトされる" do
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
      it "新規チームは作成できず、ホーム画面にリダイレクトされる" do
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
      it "新規チームを作成後、チーム管理ページに遷移する" do
        post admin_teams_path, params: team_params
        expect(response).to redirect_to(admin_teams_path)
      end
      
    end
  end

  describe "GET /admin/teams/:id/edit" do
    let(:user) do
      create(:user, admin: false)
    end
    let(:admin) do
      create(:user, admin: true)
    end
    let(:team) do
      create(
        :team,
        name: "既存チーム"
      )
    end
    
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get edit_admin_team_path(team)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "一般ユーザーがログインしている場合" do
      before do
        sign_in user
      end
      it "ホーム画面にリダイレクトされる" do
        get edit_admin_team_path(team)
        expect(response).to redirect_to(root_path)
      end
    end

    context "管理者がログインしている場合" do
      before do
        sign_in admin
      end
      it "チーム編集画面にアクセスできる" do
        get edit_admin_team_path(team)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /admin/teams/:id/update" do
    let(:user_a) do
      create(:user, admin: false)
    end
    let(:user_b) do
      create(:user, admin: false)
    end
    let(:admin) do
      create(:user, admin: true)
    end
    let!(:team) do
      create(
        :team,
        name: "変更前のチーム名",
        user_ids: [admin.id, user_b.id]
      )
    end
    let(:team_params_update) do
      {
        team: {
          name: "変更後のチーム名",
          user_ids: [admin.id, user_a.id]
        }
      }
    end

    context "ログインしていない場合" do
      it "チームは更新されず、ログインページにリダイレクトされる" do
        patch admin_team_path(team), params: team_params_update
        # チーム名の確認
        expect(Team.last.name).to eq("変更前のチーム名")
        # チームメンバーの確認
        expect(Team.last.users).to include(admin)
        expect(Team.last.users).not_to include(user_a)
        expect(Team.last.users).to include(user_b)
        # リダイレクトの確認
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "一般ユーザーがログインしている場合" do
      before do
        sign_in user_a
      end
      it "チームは更新されず、ホーム画面にリダイレクトされる" do
        patch admin_team_path(team), params: team_params_update
        # チーム名の確認
        expect(Team.last.name).to eq("変更前のチーム名")
        # チームメンバーの確認
        expect(Team.last.users).to include(admin)
        expect(Team.last.users).not_to include(user_a)
        expect(Team.last.users).to include(user_b)
        # リダイレクトの確認
        expect(response).to redirect_to(root_path)
      end
    end

    context "管理者がログインしている場合" do
      before do
        sign_in admin
      end
      it "チームを更新した後、チーム管理ページに遷移する" do
        patch admin_team_path(team), params: team_params_update
        # チーム名の確認
        expect(Team.last.name).to eq("変更後のチーム名")
        # チームメンバーの確認
        expect(Team.last.users).to include(admin)
        expect(Team.last.users).to include(user_a)
        expect(Team.last.users).not_to include(user_b)
        # リダイレクトの確認
        expect(response).to redirect_to(admin_teams_path)
      end
    end
  end

  describe "DELETE /admin/teams/:id/destroy" do
    let(:user) do
      create(:user, admin: false)
    end
    let(:admin) do
      create(:user, admin: true)
    end
    let!(:team) do
      create(
        :team,
        name: "既存チーム"
      )
    end

    context "ログインしていない場合" do
      it "チームは削除できず、ログインページにリダイレクトされる" do
        expect {
          delete admin_team_path(team)
        }.to change(Team, :count).by(0)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "一般ユーザーがログインしている場合" do
      before do
        sign_in user
      end
      it "チームは削除できず、ホーム画面にリダイレクトされる" do
        expect {
          delete admin_team_path(team)
        }.to change(Team, :count).by(0)
        expect(response).to redirect_to(root_path)
      end
    end

    context "管理者がログインしている場合" do
      before do
        sign_in admin
      end
      it "チームを削除した後、チーム管理ページに遷移する" do
        expect {
          delete admin_team_path(team)
        }.to change(Team, :count).by(-1)
        expect(response).to redirect_to(admin_teams_path)
      end
    end
  end

end


