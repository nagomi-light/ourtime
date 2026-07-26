require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:event) { build(:event) }

  describe "validations" do
    context "通常予定の場合" do
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
        expect(event.errors[:end_time]).to include("は開始時間より後にしてください")
      end
    end
    

    context "終日予定の場合" do
      it "終了日が開始日より前の場合は無効であること" do
        event.all_day = true
        event.start_time = Date.current
        event.end_time = Date.current
        expect(event).not_to be_valid
        expect(event.errors[:end_time]).to include("は開始日より後にしてください")
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:team).optional }
  end

  describe "#calendar_color" do
    let(:team) { create(:team, color: "#10B981") }

    it "チーム予定の場合はチームカラーを返す" do
      event = create(:event, team: team)
      expect(event.calendar_color).to eq("#10B981")
    end

    it "個人予定の場合は青色を返す" do
      event = create(:event, team: nil)
      expect(event.calendar_color).to eq("#3B82F6")
    end
  end

  describe "#error_attribute_name" do
    context "終日予定ではない場合" do
      let(:event) { build(:event, all_day: false) }

      it ":start_timeは開始時間を返す" do
        expect(event.error_attribute_name(:start_time)).to eq("開始時間")
      end

      it ":end_timeは終了時間を返す" do
        expect(event.error_attribute_name(:end_time)).to eq("終了時間")
      end
    end

    context "終日予定の場合" do
      let(:event) { build(:event, all_day: true) }

      it ":start_timeは開始日を返す" do
        expect(event.error_attribute_name(:start_time)).to eq("開始日")
      end

      it ":end_timeは終了日を返す" do
        expect(event.error_attribute_name(:end_time)).to eq("終了日")
      end
    end
  end
end
