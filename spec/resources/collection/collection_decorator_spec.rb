# frozen_string_literal: true
require "rails_helper"

RSpec.describe CollectionDecorator do
  subject(:decorator) { described_class.new(collection) }
  let(:collection) { FactoryBot.build(:collection) }

  it_behaves_like "a CollectionDecorator"

  describe "#title" do
    it "exposes the title" do
      expect(decorator.title).to eq "Title"
    end
  end

  describe "#owners" do
    let(:collection) do
      FactoryBot.build(:collection,
                       owners: ["owner"])
    end
    it "displays the owners" do
      expect(decorator.display_attributes[:owners]).to eq ["owner"]
    end
  end
end