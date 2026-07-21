require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:event) { build(:event) }

  describe "validations" do
    it "有効なFactoryを持つこと" do
      expect(event).to be_valid
    end
    
    it "タイトルが必須であること" do
      event.title = nil
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("を入力してください")
    end

    it "開始日時が必須であること" do
      event.start_time = nil
      expect(event).not_to be_valid
      expect(event.errors[:start_time]).to include("を入力してください")
    end

    it "終了日時が必須であること" do
      event.end_time = nil
      expect(event).not_to be_valid
      expect(event.errors[:end_time]).to include("を入力してください")
    end

    it "終了日時が開始日時より前の場合は無効であること" do
      event.start_time = Time.current
      event.end_time = 1.hour.ago
      expect(event).not_to be_valid
      expect(event.errors[:end_time]).to include("は開始日時より後にしてください")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:team).optional }
  end

  describe "#calendar_color" do
    let(:team) { create(:team, color: "#3B82F6") }

    it "チーム予定の場合はチームカラーを返す" do
      event = create(:event, team: team)
      expect(event.calendar_color).to eq("#3B82F6")
    end

    it "個人予定の場合は黒を返す" do
      event = create(:event, team: nil)
      expect(event.calendar_color).to eq("#222222")
    end
  end
end
