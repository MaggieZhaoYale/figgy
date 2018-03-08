# frozen_string_literal: true
require 'rails_helper'

RSpec.describe RasterResourceDecorator do
  subject(:decorator) { described_class.new(resource) }
  let(:resource) do
    FactoryBot.build(:raster_resource,
                     title: "test title",
                     author: "test author",
                     creator: "test creator",
                     subject: "test subject")
  end
  it "exposes markup for rights statement" do
    expect(resource.decorate.rendered_rights_statement).not_to be_empty
    expect(resource.decorate.rendered_rights_statement.first).to match(/#{Regexp.escape('http://rightsstatements.org/vocab/NKC/1.0/')}/)
  end
  it "exposes markup for rendered coverage" do
    expect(resource.decorate.rendered_coverage).to match(/#{Regexp.escape('boundingBoxSelector')}/)
    expect(resource.decorate.rendered_coverage).to match(/#{Regexp.escape('Toggle Map')}/)
  end
  it "can attach child members" do
    expect(resource.decorate.attachable_objects).to include RasterResource
  end
  it "cannot manage structure" do
    expect(decorator.manageable_structure?).to be false
  end
  context "with file sets" do
    let(:file_set) do
      adapter = Valkyrie::MetadataAdapter.find(:indexing_persister)
      res = FactoryBot.build(:file_set)
      adapter.persister.save(resource: res)
    end
    let(:resource) { FactoryBot.create_for_repository(:raster_resource, member_ids: [file_set.id]) }
    it "retrieves members" do
      expect(resource.decorate.members.to_a).not_to be_empty
      expect(resource.decorate.members.to_a.first).to be_a FileSet
    end
  end
end