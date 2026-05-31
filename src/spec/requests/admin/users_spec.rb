require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  describe "GET /admin/users" do
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get admin_users_path
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
        get admin_users_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "管理者がログインしている場合" do
      let(:admin) do
        create(:user, admin: true)
      end
      let!(:user_a) { create(:user, name: "ユーザーA") }
      let!(:user_b) { create(:user, name: "ユーザーB") }
      before do
        sign_in admin
      end
      it "ユーザー管理ページにアクセスできる" do
        get admin_users_path
        expect(response).to have_http_status(:ok)
      end
      it "チームの一覧が表示される" do
        get admin_users_path
        expect(response.body).to include("ユーザーA")
        expect(response.body).to include("ユーザーB")
      end
    end
  end

  describe "GET /admin/users/new" do
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get new_admin_user_path
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
        get new_admin_user_path
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
      it "新規ユーザーの作成画面にアクセスできる" do
        get new_admin_user_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /admin/users" do
    let(:user_params) do
      {
        user: {
          name: "新規ユーザー",
          email: "test@example.com",
          admin: false
        }
      }
    end
    context "ログインしていない場合" do
      it "新規ユーザーは招待できず、ログインページにリダイレクトされる" do
        expect {
          post admin_users_path, params: user_params
        }.not_to change(User, :count)
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
      it "新規チームは作成できず、ホーム画面にリダイレクトされる" do
        expect {
          post admin_users_path, params: user_params
        }.not_to change(User, :count)
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
      context "正常なパラメータの場合" do
        it "新規ユーザーを作成した後、チーム管理ページに遷移する" do
          expect {
            post admin_users_path, params: user_params
          }.to change(User, :count).by(1)
          #招待中のユーザーが作成されている
          user = User.last
          expect(user.invitation_token).to be_present
          expect(user.invitation_accepted_at).to be_nil

          expect(response).to redirect_to(admin_users_path)
        end
        it "招待メールが送信される" do
          post admin_users_path, params: user_params
          mail = ActionMailer::Base.deliveries.last
          expect(mail).to be_present
          expect(mail.to).to eq(["test@example.com"])
          expect(mail.html_part.body.decoded).to include("OURTIME に招待されました")
        end
      end
      context "ユーザー名が空欄の場合" do
        let(:user_params) do
          {
            user: {
              name: "",
              email: "test@example.com",
              admin: false
            }
          }
        end
        it "新規ユーザーを作成できない" do
          expect {
            post admin_users_path, params: user_params
          }.not_to change(User, :count)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
      context "メールアドレスが空欄の場合" do
        let(:user_params) do
          {
            user: {
              name: "新規ユーザー",
              email: "",
              admin: false
            }
          }
        end
        it "新規ユーザーを作成できない" do
          expect {
            post admin_users_path, params: user_params
          }.not_to change(User, :count)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
      context "メールアドレスに重複がある場合" do
        let!(:existing_user) do
          create(:user, email: "test@example.com")
        end
        it "新規ユーザーを作成できない" do
          expect {
            post admin_users_path, params: user_params
          }.not_to change(User, :count)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  # describe "GET /admin/teams/:id/edit" do
  #   let(:user) do
  #     create(:user, admin: false)
  #   end
  #   let(:admin) do
  #     create(:user, admin: true)
  #   end
  #   let(:team) do
  #     create(
  #       :team,
  #       name: "既存チーム",
  #       owner: admin
  #     )
  #   end
    
  #   context "ログインしていない場合" do
  #     it "ログインページにリダイレクトされる" do
  #       get edit_admin_team_path(team)
  #       expect(response).to redirect_to(new_user_session_path)
  #     end
  #   end

  #   context "一般ユーザーがログインしている場合" do
  #     before do
  #       sign_in user
  #     end
  #     it "ホーム画面にリダイレクトされる" do
  #       get edit_admin_team_path(team)
  #       expect(response).to redirect_to(root_path)
  #     end
  #   end

  #   context "管理者がログインしている場合" do
  #     before do
  #       sign_in admin
  #     end
  #     it "チーム編集画面にアクセスできる" do
  #       get edit_admin_team_path(team)
  #       expect(response).to have_http_status(:ok)
  #     end
  #   end
  # end

  # describe "PATCH /admin/teams/:id/update" do
  #   let(:user_a) do
  #     create(:user, admin: false)
  #   end
  #   let(:user_b) do
  #     create(:user, admin: false)
  #   end
  #   let(:admin) do
  #     create(:user, admin: true)
  #   end
  #   let!(:team) do
  #     create(
  #       :team,
  #       name: "変更前のチーム名",
  #       user_ids: [admin.id, user_b.id],
  #       owner: admin
  #     )
  #   end
  #   let(:team_params_update) do
  #     {
  #       team: {
  #         name: "変更後のチーム名",
  #         user_ids: [admin.id, user_a.id]
  #       }
  #     }
  #   end

  #   context "ログインしていない場合" do
  #     it "チームは更新されず、ログインページにリダイレクトされる" do
  #       patch admin_team_path(team), params: team_params_update
  #       # チーム名の確認
  #       expect(Team.last.name).to eq("変更前のチーム名")
  #       # チームメンバーの確認
  #       expect(Team.last.users).to include(admin)
  #       expect(Team.last.users).not_to include(user_a)
  #       expect(Team.last.users).to include(user_b)
  #       # リダイレクトの確認
  #       expect(response).to redirect_to(new_user_session_path)
  #     end
  #   end

  #   context "一般ユーザーがログインしている場合" do
  #     before do
  #       sign_in user_a
  #     end
  #     it "チームは更新されず、ホーム画面にリダイレクトされる" do
  #       patch admin_team_path(team), params: team_params_update
  #       # チーム名の確認
  #       expect(Team.last.name).to eq("変更前のチーム名")
  #       # チームメンバーの確認
  #       expect(Team.last.users).to include(admin)
  #       expect(Team.last.users).not_to include(user_a)
  #       expect(Team.last.users).to include(user_b)
  #       # リダイレクトの確認
  #       expect(response).to redirect_to(root_path)
  #     end
  #   end

  #   context "管理者がログインしている場合" do
  #     before do
  #       sign_in admin
  #     end
  #     it "チームを更新した後、チーム管理ページに遷移する" do
  #       patch admin_team_path(team), params: team_params_update
  #       # チーム名の確認
  #       expect(Team.last.name).to eq("変更後のチーム名")
  #       # チームメンバーの確認
  #       expect(Team.last.users).to include(admin)
  #       expect(Team.last.users).to include(user_a)
  #       expect(Team.last.users).not_to include(user_b)
  #       # リダイレクトの確認
  #       expect(response).to redirect_to(admin_teams_path)
  #     end
  #   end
  # end

  # describe "DELETE /admin/teams/:id/destroy" do
  #   let(:user) do
  #     create(:user, admin: false)
  #   end
  #   let(:admin) do
  #     create(:user, admin: true)
  #   end
  #   let!(:team) do
  #     create(
  #       :team,
  #       name: "既存チーム"
  #     )
  #   end

  #   context "ログインしていない場合" do
  #     it "チームは削除できず、ログインページにリダイレクトされる" do
  #       expect {
  #         delete admin_team_path(team)
  #       }.to change(Team, :count).by(0)
  #       expect(response).to redirect_to(new_user_session_path)
  #     end
  #   end

  #   context "一般ユーザーがログインしている場合" do
  #     before do
  #       sign_in user
  #     end
  #     it "チームは削除できず、ホーム画面にリダイレクトされる" do
  #       expect {
  #         delete admin_team_path(team)
  #       }.to change(Team, :count).by(0)
  #       expect(response).to redirect_to(root_path)
  #     end
  #   end

  #   context "管理者がログインしている場合" do
  #     before do
  #       sign_in admin
  #     end
  #     it "チームを削除した後、チーム管理ページに遷移する" do
  #       expect {
  #         delete admin_team_path(team)
  #       }.to change(Team, :count).by(-1)
  #       expect(response).to redirect_to(admin_teams_path)
  #     end
  #   end
  # end

end
