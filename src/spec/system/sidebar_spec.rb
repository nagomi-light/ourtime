require "rails_helper"

RSpec.describe "Sidebar", type: :system do
  let!(:user) do
    create(:user, password: "password", password_confirmation: "password")
  end

  before do
    login_as(user, scope: :user)
  end

  describe "サイドバー機能", js: true do
    let!(:team) { create(:team, name: "営業チーム") }
    let!(:teammate) { create(:user, name: "山田") }

    before do
      create(:team_member, team: team, user: user)
      create(:team_member, team: team, user: teammate)

      create(:event,
        title: "営業会議",
        user: teammate,
        team: team,
        start_time: Time.current,
        end_time: 1.hour.from_now
      )

      visit root_path
    end

    it "展開ボタンでメンバーが表示される" do
      expect(page).to have_css("#team-members-#{team.id}.hidden")
      find("button[data-team-id='#{team.id}']").click
      expect(page).to have_content("山田")
    end

    it "チームのチェックを外すと予定が消える" do
      expect(page).to have_content("営業会議")
      find("input.team-toggle[value='#{team.id}']").uncheck
      expect(page).not_to have_content("営業会議", wait: 5)
    end

    it "チームのチェックを外すとメンバーのチェックも外れる" do
      find("button[data-team-id='#{team.id}']").click
      team_checkbox = find("input.team-toggle[value='#{team.id}']")
      user_checkbox = find("#team-members-#{team.id} .user-toggle", match: :first)

      expect(user_checkbox).to be_checked
      find("input.team-toggle[value='#{team.id}']").uncheck
      expect(user_checkbox).not_to be_checked
    end

    it "チームのチェックを入れるとメンバーのチェックも入る" do
      find("button[data-team-id='#{team.id}']").click
      team_checkbox = find("input.team-toggle[value='#{team.id}']")
      user_checkbox = find("#team-members-#{team.id} .user-toggle", match: :first)

      find("input.team-toggle[value='#{team.id}']").uncheck
      expect(user_checkbox).not_to be_checked
      find("input.team-toggle[value='#{team.id}']").check
      expect(user_checkbox).to be_checked
    end

    it "ユーザーのチェックを外すとカレンダーから予定が消える" do
      find("button[data-team-id='#{team.id}']").click
      expect(page).to have_content("営業会議")
      find("input.user-toggle[value='#{teammate.id}']").uncheck
      expect(page).not_to have_content("営業会議", wait: 5)
    end
  end
end