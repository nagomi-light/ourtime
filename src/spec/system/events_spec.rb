require "rails_helper"

RSpec.describe "Events", type: :system do
  let!(:user) do
    create(:user, password: "password", password_confirmation: "password")
  end
  let(:event) do
    create(:event,
      user: user,
      title: "自分の予定",
      description: "予定の説明",
      start_time: Time.zone.now,
      end_time: 1.hour.from_now
    )
  end

  before do
    login_as(user, scope: :user)
  end

  describe "予定の作成" do
    it "予定作成画面から予定を作成できる" do
      visit root_path
      click_link "新規予定の作成"
      expect(page).to have_current_path(new_event_path)
      fill_in "event[title]", with: "予定のタイトル"
      fill_in "event[description]", with: "予定の説明"
      click_button "作成"
      expect(page).to have_current_path(events_path)
      expect(page).to have_content("予定のタイトル")
    end
  end

  describe "予定の詳細", js: true do
    context "自分が作成した予定の場合" do
      let!(:event) do
        create(:event,
          user: user,
          title: "自分の予定",
          description: "予定の説明",
          start_time: Time.zone.now,
          end_time: 1.hour.from_now
        )
      end
      it "カレンダーの予定をクリックすると詳細画面へ遷移し、編集ボタンと削除ボタンが表示される" do
        visit root_path
        find(".fc-event", text: event.title).click
        expect(page).to have_current_path(event_path(event))
        expect(page).to have_content(event.title)
        expect(page).to have_content(event.description)
        expect(page).to have_link("編集")
        expect(page).to have_button("削除")
      end
    end


    context "同じチームの予定の場合" do
      let(:team) { create(:team) }
      let(:teammate) { create(:user) }

      before do
        create(:team_member, team: team, user: user)
        create(:team_member, team: team, user: teammate)
      end

      let!(:event) do
        create(:event,
          user: teammate,
          team: team,
          title: "チーム予定",
          description: "予定の説明",
          start_time: Time.zone.now,
          end_time: 1.hour.from_now
        )
      end

      it "カレンダーの予定をクリックすると詳細画面へ遷移するが、作成者以外には編集ボタンと削除ボタンが表示されない" do
        visit root_path
        find(".fc-event", text: event.title).click
        expect(page).to have_current_path(event_path(event))
        expect(page).to have_content(event.title)
        expect(page).to have_content(event.description)
        expect(page).not_to have_link("編集")
        expect(page).not_to have_button("削除")
      end
    end
  end

  

  describe "予定の編集" do
    it "編集画面から予定を編集できる" do
      visit event_path(event)
      click_link "編集"
      expect(page).to have_current_path(edit_event_path(event))
      fill_in "event[title]", with: "編集後のタイトル"
      fill_in "event[description]", with: "編集後の説明"
      click_button '更新'
      expect(page).to have_current_path(events_path)
      expect(page).to have_content("編集後のタイトル")
    end
  end

  describe "予定の削除" do
    it "詳細画面から予定を削除できる" do
      visit event_path(event)
      accept_confirm do
        click_button "削除"
      end
      expect(page).to have_current_path(events_path)
      expect(page).not_to have_content("自分の予定")
    end
  end
end