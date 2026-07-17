require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:team) { build(:team) }

  describe "validations" do
    it "有効なFactoryを持つこと" do
      expect(team).to be_valid
    end

    it "チーム名が必須であること" do
      team.name = nil
      expect(team).not_to be_valid
      expect(team.errors[:name]).to include("を入力してください")
    end

  end

  describe "associations" do
    it { is_expected.to have_many(:events).dependent(:destroy) }
    it { is_expected.to have_many(:team_members).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:team_members) }
  end
end
