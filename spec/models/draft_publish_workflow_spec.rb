# frozen_string_literal: true
require 'rails_helper'

describe DraftPublishWorkflow do
  subject(:workflow) { described_class.new 'draft' }

  describe 'ingest workflow' do
    it 'proceeds through ingest workflow' do
      # initial state: draft
      expect(workflow.draft?).to be true
      expect(workflow.may_publish?).to be true
      expect(workflow.published?).to be false
      expect(workflow.suppressed?).to eq false
      expect(workflow.valid_transitions).to contain_exactly "published"

      expect(workflow.publish).to be true
      expect(workflow.published?).to be true
      expect(workflow.may_unpublish?).to eq true
      expect(workflow.draft?).to eq false
      expect(workflow.suppressed?).to eq false
      expect(workflow.valid_transitions).to contain_exactly "draft"

      expect(workflow.unpublish).to eq true
      expect(workflow.draft?).to eq true
      expect(workflow.published?).to eq false
      expect(workflow.may_publish?).to eq true
      expect(workflow.suppressed?).to eq false
      expect(workflow.valid_transitions).to contain_exactly "published"
    end
  end

  it 'reports valid states' do
    expect(workflow.valid_states).to eq %w[draft published]
  end
end
