# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "Manage Users", js: true do
  let(:user) { FactoryBot.create(:admin) }

  before do
    sign_in user
  end

  context "when an admin adds a new user" do
    it "has provider: 'cas'" do
      visit users_path
      page.fill_in 'user_uid', with: 'zelda'
      page.find('form.new_user').native.submit

      expect(User.last.uid).to eq 'zelda'
      expect(User.last.provider).to eq 'cas'
    end
  end
end
