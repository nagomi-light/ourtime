require "rails_helper"

RSpec.describe "Admin::Teams", type: :system do
  let!(:admin) do
    create(:user, name: "管理者", password: "password", password_confirmation: "password", admin: true)
  end

  let!(:user_a) do
    create(:user, name: "ユーザーA")
  end
  let!(:user_b) do
    create(:user, name: "ユーザーB")
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

  describe "チームの一覧" do
    it "ヘッダーのメニューから、チーム一覧に遷移できる" do
      visit root_path
      find("button[data-action='click->dropdown#toggle']").click
      click_link "チーム管理"
      expect(page).to have_current_path(admin_teams_path)
      within("#team-#{team_1.id}") do
        expect(page).to have_content("既存チーム1")
        expect(page).to have_content("管理者")
        expect(page).to have_content("ユーザーA")
        expect(page).not_to have_content("ユーザーB")
      end
      within("#team-#{team_2.id}") do
        expect(page).to have_content("既存チーム2")
        expect(page).to have_content("管理者")
        expect(page).not_to have_content("ユーザーA")
        expect(page).to have_content("ユーザーB")
      end
    end
  end

  describe "チームの作成" do
    it "チームの作成画面からチームを作成できる" do
      visit admin_teams_path
      click_link "新規チームの作成"
      expect(page).to have_current_path(new_admin_team_path)
      fill_in "team[name]", with: "新しいチーム"
      find("input[value='#{admin.id}']").check 
      click_button "作成"
      expect(page).to have_current_path(admin_teams_path)
      new_team = Team.order(:created_at).last
      within("#team-#{new_team.id}") do
        expect(page).to have_content("新しいチーム")
        expect(page).to have_content("管理者")
        expect(page).not_to have_content("ユーザーA")
        expect(page).not_to have_content("ユーザーB")
      end
    end
  end

  describe "チームの編集" do
    it "チームの編集画面からチームを編集できる" do
      visit admin_teams_path
      within("#team-#{team_1.id}") do
        find("a[href='#{edit_admin_team_path(team_1)}']").click
      end
      expect(page).to have_current_path(edit_admin_team_path(team_1))
      fill_in "team[name]", with: "編集後のチーム"
      find("input[value='#{admin.id}']").uncheck 
      find("input[value='#{user_a.id}']").check 
      find("input[value='#{user_b.id}']").check 
      click_button "更新"
      expect(page).to have_current_path(admin_teams_path)
      within("#team-#{team_1.id}") do
        expect(page).to have_content("編集後のチーム")
        expect(page).not_to have_content("管理者")
        expect(page).to have_content("ユーザーA")
        expect(page).to have_content("ユーザーB")
      end
    end
  end

  describe "チームの削除" do
    it "チーム一覧からチームを削除できる" do
      visit admin_teams_path
      expect(page).to have_css("#team-#{team_1.id}")
      expect(page).to have_css("#team-#{team_2.id}")
      within("#team-#{team_1.id}") do
        accept_confirm do
          find("a[href='#{admin_team_path(team_1)}']").click
        end
      end
      expect(page).to have_current_path(admin_teams_path)
      expect(page).not_to have_css("#team-#{team_1.id}")
      expect(page).to have_css("#team-#{team_2.id}")
    end
  end
end