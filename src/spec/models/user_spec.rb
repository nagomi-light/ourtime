require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe "validations" do
    it "有効なFactoryを持つこと" do
      expect(user).to be_valid
    end

    it "ユーザー名が必須であること" do
      user.name = nil
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("を入力してください")
    end

    it "メールアドレスが必須であること" do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "メールアドレスは一意であること" do
      existing_user = create(:user)
      duplicate_user = build(:user, email: existing_user.email)
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include("はすでに存在します")
    end

    it "パスワードが6文字未満の場合は無効であること" do
      user = build(:user, password: "12345", password_confirmation: "12345")
      expect(user).not_to be_valid
    end

    it "パスワードが空欄の場合は無効であること" do
      user = build(:user, password: "", password_confirmation: "")
      expect(user).not_to be_valid
    end

    it "確認用パスワードと一致しない場合は無効であること" do
      user = build(:user, password: "password", password_confirmation: "different")
      expect(user).not_to be_valid
    end

  end

  describe "associations" do
    it { is_expected.to have_many(:events).dependent(:destroy) }
    it { is_expected.to have_many(:team_members).dependent(:destroy) }
    it { is_expected.to have_many(:teams).through(:team_members) }
  end
end
