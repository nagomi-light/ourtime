require "rails_helper"

RSpec.describe "Header", type: :system do
  describe "ログインしていない場合" do
    it "ヘッダーにログインボタンが表示される" do
      visit root_path
      expect(page).to have_link("ログイン")
    end
  end

  describe "一般ユーザーがログインしている場合" do
    let(:user) do
      create(:user, name: "ユーザー名", admin: false)
    end
    before do
      sign_in user
    end
    it "ヘッダーにユーザー名が表示される" do
      visit root_path
      expect(page).to have_content("ユーザー名")
    end
    it "ドロップダウンメニューを開くと、一般ユーザー向けのメニューのみ表示される" do
      visit root_path
      expect(page).to have_css("#user-menu.hidden")
      find("button[data-action='click->dropdown#toggle']").click
      expect(page).not_to have_link("チーム管理")
      expect(page).not_to have_link("ユーザー管理")
      expect(page).to have_link("パスワード変更")
      expect(page).to have_button("ログアウト")
    end
  end

  describe "管理者がログインしている場合" do
    let(:admin) do
      create(:user, name: "管理者名", admin: true)
    end
    before do
      sign_in admin
    end
    it "ヘッダーに管理者名が表示される" do
      visit root_path
      expect(page).to have_content("管理者名")
    end
    it "ドロップダウンメニューを開くと、管理者向けのメニューも表示される" do
      visit root_path
      expect(page).to have_css("#user-menu.hidden")
      find("button[data-action='click->dropdown#toggle']").click
      expect(page).to have_link("チーム管理")
      expect(page).to have_link("ユーザー管理")
      expect(page).to have_link("パスワード変更")
      expect(page).to have_button("ログアウト")
    end
  end
end