require "rails_helper"

RSpec.describe "Admin::Users", type: :system do
  let!(:admin) do
    create(:user, name: "管理者", email: "admin@example.com", password: "password", password_confirmation: "password", admin: true)
  end

  let!(:user_a) do
    create(:user, name: "ユーザーA", email: "user_a@example.com", admin: false)
  end
  let!(:user_b) do
    create(:user, name: "ユーザーB", email: "user_b@example.com", admin: false)
  end


  let!(:team_1) do
    create(:team,
      name: "既存チーム1",
      user_ids: [admin.id, user_a.id]
    )
  end
  let!(:team_2) do
    create(:team,
      name: "既存チーム2",
      user_ids: [admin.id, user_b.id]
    )
  end

  before do
    login_as(admin, scope: :user)
  end

  describe "ユーザーの一覧" do
    it "ヘッダーのメニューから、ユーザーの一覧に遷移できる" do
      visit root_path
      find("button[data-action='click->dropdown#toggle']").click
      click_link "ユーザー管理"
      expect(page).to have_current_path(admin_users_path)
      within("#user-#{admin.id}") do
        expect(page).to have_content("管理者")
        expect(page).to have_content("admin@example.com")
        expect(page).to have_content("既存チーム1")
        expect(page).to have_content("既存チーム2")
      end
      within("#user-#{user_a.id}") do
        expect(page).to have_content("ユーザーA")
        expect(page).to have_content("user_a@example.com")
        expect(page).to have_content("既存チーム1")
        expect(page).not_to have_content("既存チーム2")
      end
      within("#user-#{user_b.id}") do
        expect(page).to have_content("ユーザーB")
        expect(page).to have_content("user_b@example.com")
        expect(page).not_to have_content("既存チーム1")
        expect(page).to have_content("既存チーム2")
      end
    end
  end

  describe "ユーザーの招待" do
    it "ユーザーの作成画面からユーザーを招待(作成)できる" do
      visit admin_users_path
      click_link "新規ユーザーの招待"
      expect(page).to have_current_path(new_admin_user_path)
      fill_in "user[name]", with: "新しいユーザー"
      fill_in "user[email]", with: "new_user@example.com"
      find("input[name='user[team_ids][]'][value='#{team_1.id}']").check
      find("input[name='user[team_ids][]'][value='#{team_2.id}']").uncheck
      click_button "招待"
      expect(page).to have_current_path(admin_users_path)
      new_user = User.order(:created_at).last
      within("#user-#{new_user.id}") do
        expect(page).to have_content("新しいユーザー")
        expect(page).to have_content("new_user@example.com")
        expect(page).to have_content("既存チーム1")
        expect(page).not_to have_content("既存チーム2")
      end
      expect(new_user.admin).to be false
    end
    it "ユーザーの作成画面から管理者を招待(作成)できる" do
      visit admin_users_path
      click_link "新規ユーザーの招待"
      expect(page).to have_current_path(new_admin_user_path)
      fill_in "user[name]", with: "新しい管理者"
      fill_in "user[email]", with: "new_admin@example.com"
      find("input[name='user[team_ids][]'][value='#{team_1.id}']").check
      check "user_admin", allow_label_click: true
      click_button "招待"
      expect(page).to have_current_path(admin_users_path)
      new_admin = User.order(:created_at).last
      within("#user-#{new_admin.id}") do
        expect(page).to have_content("新しい管理者")
        expect(page).to have_content("new_admin@example.com")
        expect(page).to have_content("既存チーム1")
      end
      expect(new_admin.admin).to be true
    end
  end

  describe "ユーザーの編集" do
    it "ユーザーの編集画面からユーザーを編集できる" do
      visit admin_users_path
      within("#user-#{user_a.id}") do
        find("a[href='#{edit_admin_user_path(user_a)}']").click
      end
      expect(page).to have_current_path(edit_admin_user_path(user_a))
      fill_in "user[name]", with: "編集後のユーザー"
      find("input[name='user[team_ids][]'][value='#{team_1.id}']").uncheck
      find("input[name='user[team_ids][]'][value='#{team_2.id}']").check
      check "user_admin", allow_label_click: true
      click_button "更新"
      expect(page).to have_current_path(admin_users_path)
      within("#user-#{user_a.id}") do
        expect(page).to have_content("編集後のユーザー")
        expect(page).to have_content("user_a@example.com")
        expect(page).not_to  have_content("既存チーム1")
        expect(page).to have_content("既存チーム2")
      end
      expect(user_a.reload.admin).to be(true)
    end
  end

  describe "ユーザーの削除" do
    it "ユーザーの一覧からユーザーを削除できる" do
      visit admin_users_path
      expect(page).to have_css("#user-#{admin.id}")
      expect(page).to have_css("#user-#{user_a.id}")
      expect(page).to have_css("#user-#{user_b.id}")
      within("#user-#{user_a.id}") do
        accept_confirm do
          find("a[href='#{admin_user_path(user_a)}']").click
        end
      end
      expect(page).to have_current_path(admin_users_path)
      expect(page).to have_css("#user-#{admin.id}")
      expect(page).not_to have_css("#user-#{user_a.id}")
      expect(page).to have_css("#user-#{user_b.id}")
    end
  end
end