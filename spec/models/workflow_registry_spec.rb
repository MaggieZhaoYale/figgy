# frozen_string_literal: true
require 'rails_helper'

RSpec.describe WorkflowRegistry do
  describe ".register" do
    before do
      class MyResource < Valhalla::Resource; end
      class MyWorkflow; end
    end

    after do
      Object.send(:remove_const, :MyResource)
      Object.send(:remove_const, :MyWorkflow)
    end

    it "adds an entry for the pair" do
      expect(described_class.register(resource_class: MyResource, workflow_class: MyWorkflow)).to be true
      expect(described_class.workflow_for(MyResource)).to eq MyWorkflow
    end
  end
  describe ".workflow_for" do
    context "when given a resource that is registered" do
      it "returns the workflow class" do
        expect(described_class.workflow_for(SimpleResource)).to eq DraftPublishWorkflow
      end
    end

    context "when given a resource that isn't registered" do
      before { class TotallyNotAResource; end }
      after { Object.send(:remove_const, :TotallyNotAResource) }

      it "throws exception" do
        expect { described_class.workflow_for(TotallyNotAResource) }.to raise_error(WorkflowRegistry::EntryNotFound, "TotallyNotAResource")
      end
    end
  end
end
