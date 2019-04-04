# frozen_string_literal: true
require "rails_helper"

describe NumismaticCitation do
  subject(:numismatic_citation) { described_class.new part: "first", number: "2" }

  it "has properties" do
    expect(numismatic_citation.part).to eq(["first"])
    expect(numismatic_citation.number).to eq(["2"])
  end
end
