# frozen_string_literal: true
require "rails_helper"

RSpec.describe NumismaticSubjectChangeSet do
  subject(:change_set) { described_class.new(numismatic_subject) }
  let(:numismatic_subject) { NumismaticSubject.new }

  describe "#primary_terms" do
    it "includes displayed fields" do
      expect(change_set.primary_terms).to include(:type, :subject)
    end
  end
end
