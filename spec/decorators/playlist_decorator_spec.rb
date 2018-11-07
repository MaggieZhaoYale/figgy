# frozen_string_literal: true
require "rails_helper"

RSpec.describe PlaylistDecorator do
  subject(:decorator) { described_class.new(playlist) }
  let(:playlist) { FactoryBot.create_for_repository(:playlist) }

  it "does not manage structure" do
    expect(decorator.manageable_structure?).to be false
  end

  it "does manage files" do
    expect(decorator.manageable_files?).to be true
  end

  it "delegates members to wayfinder" do
    expect(decorator.members).to be_empty
  end

  describe "#title" do
    it "uses the label" do
      expect(decorator.title).to eq playlist.label
    end
  end
end
