# frozen_string_literal: true
require "rails_helper"

describe NumismaticArtist do
  subject(:artist) { described_class.new person: "eric", signature: "eric-one", role: "main-role", side: "reverse-side" }

  it "has properties" do
    expect(artist.person).to eq(["eric"])
    expect(artist.signature).to eq(["eric-one"])
    expect(artist.role).to eq(["main-role"])
    expect(artist.side).to eq(["reverse-side"])
  end
end