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
      all_day: false,
      start_time: Time.zone.now,
      end_time: 1.hour.from_now
    )
  end

  before do
    login_as(user, scope: :user)
  end

  describe "予定の作成" do
    it "予定作成画面では、終日のチェックボックスによって画面表示が変化する" do
      visit root_path
      click_link "新規予定の作成"
      expect(page).to have_current_path(new_event_path)
      # 初期状態の場合
      expect(page).to have_css("[data-all-day-target='timeFields']", visible: true)
      expect(page).to have_css("[data-all-day-target='dateFields']", visible: false)

      # チェックボックスにチェックをいれた場合
      check "終日" 
      expect(page).to have_css("[data-all-day-target='timeFields']", visible: false) 
      expect(page).to have_css("[data-all-day-target='dateFields']", visible: true)
      
      # チェックボックスのチェックを外した場合 
      uncheck "終日"
      expect(page).to have_css("[data-all-day-target='timeFields']", visible: true) 
      expect(page).to have_css("[data-all-day-target='dateFields']", visible: false)
    end

    it "予定作成画面から、指定した時間の予定を作成できる" do
      visit root_path
      click_link "新規予定の作成"
      expect(page).to have_current_path(new_event_path)
      fill_in "event[title]", with: "予定のタイトル"
      fill_in "event[description]", with: "予定の説明"
      uncheck "終日"
      fill_in "event[start_time]", with: Time.zone.now
      fill_in "event[end_time]", with: 1.hour.from_now
      click_button "作成"
      expect(page).to have_current_path(events_path)
      expect(page).to have_content("予定のタイトル")
      expect(Event.last.all_day).to be false
    end
    it "予定作成画面から、終日予定を作成できる" do
      visit root_path
      click_link "新規予定の作成"
      expect(page).to have_current_path(new_event_path)
      fill_in "event[title]", with: "終日予定"
      check "終日"
      fill_in "event[start_time]", with: Time.zone.today
      fill_in "event[end_time]", with: Time.zone.today
      click_button "作成"
      expect(page).to have_current_path(events_path)
      expect(page).to have_content("終日予定")
      expect(Event.last.all_day).to be true
      expect(Event.last.start_time).to eq(Time.zone.today.beginning_of_day)
      expect(Event.last.end_time).to eq(Time.zone.tomorrow.beginning_of_day)
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

    context "終日予定ではない場合" do
      let!(:event) do
        create(:event,
          user: user,
          title: "終日ではない予定",
          start_time: Time.zone.now,
          end_time: 1.hour.from_now,
          all_day: false
        )
      end

      it "詳細画面では、Y/M/D HH:MM～Y/M/D HH:MM形式で時間が表記される" do
        visit root_path
        find(".fc-event", text: event.title).click
        expect(page).to have_current_path(event_path(event))
        expect(page).to have_content("#{event.start_time.strftime("%Y/%m/%d %H:%M")}～#{event.end_time.strftime("%Y/%m/%d %H:%M")}")
      end
    end

    context "終日予定の場合" do
      let!(:event) do
        create(:event,
          user: user,
          title: "終日予定",
          start_time: Time.zone.now.to_date,
          end_time: 1.day.from_now.to_date,
          all_day: true
        )
      end

      it "詳細画面では、Y/M/D～Y/M/D形式で時間が表記される" do
        visit root_path
        find(".fc-event", text: event.title).click
        expect(page).to have_current_path(event_path(event))
        expect(page).to have_content("#{event.start_time.strftime("%Y/%m/%d")}～#{event.end_time.strftime("%Y/%m/%d")}")
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
      check "終日"
      fill_in "event[start_time]", with: Time.zone.today
      fill_in "event[end_time]", with: Time.zone.today
      click_button "更新"
      expect(page).to have_current_path(events_path)
      expect(page).to have_content("編集後のタイトル")
      expect(Event.last.all_day).to be true
      expect(Event.last.start_time).to eq(Time.zone.today.beginning_of_day)
      expect(Event.last.end_time).to eq(Time.zone.tomorrow.beginning_of_day)
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