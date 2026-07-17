require 'rails_helper'

RSpec.describe TeamMember, type: :model do
  describe "validations" do
    subject { create(:team_member) }

    it do
        is_expected.to validate_uniqueness_of(:user_id).scoped_to(:team_id)
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:team) }
  end
end
