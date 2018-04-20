# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Valkyrie::ResourceDecorator do
  subject(:decorator) { described_class.new(resource) }
  let(:resource) { FactoryBot.build(:scanned_resource) }

  describe '#members' do
    let(:child_resource) { FactoryBot.create_for_repository(:scanned_resource) }
    let(:resource) { FactoryBot.create_for_repository(:scanned_resource, member_ids: [child_resource.id]) }

    it 'retrieves all member resources' do
      expect(decorator.members.to_a).not_to be_empty
    end
  end

  describe '#parents' do
    let(:resource) { FactoryBot.create_for_repository(:scanned_resource) }
    let(:parent_resource) { FactoryBot.create_for_repository(:scanned_resource, member_ids: [resource.id]) }
    before do
      parent_resource
    end

    it 'retrieves all parent resources' do
      expect(decorator.parents.to_a).not_to be_empty
    end
  end

  describe '#iiif_metadata' do
    context 'when viewing a new Scanned Resource' do
      let(:resource) do
        FactoryBot.create_for_repository(:scanned_resource,
                                         title: ['test title'],
                                         pdf_type: ['Gray'],
                                         identifier: ["http://arks.princeton.edu/ark:/88435/5m60qr98h"],
                                         created: ['01/01/1970'])
      end
      let(:metadata) { resource.decorate.iiif_metadata }

      it 'returns iiif attributes in label/value key/val hash pairs' do
        expect(metadata).to be_an Array
        expect(metadata).to include("label" => "Title", "value" => ["test title"])
        expect(metadata).to include("label" => "Identifier", "value" => \
          ["<a href='http://arks.princeton.edu/ark:/88435/5m60qr98h' alt='Identifier'>http://arks.princeton.edu/ark:/88435/5m60qr98h</a>"])
        expect(metadata).to include("label" => "PDF Type", "value" => ["Gray"])
        expect(metadata).to include("label" => "Created", "value" => ['01/01/1970'])
      end
    end

    context 'when viewing an Ephemera Project' do
      let(:resource) { FactoryBot.create_for_repository(:ephemera_project, slug: "lae-d957") }
      let(:metadata) { resource.decorate.iiif_metadata }

      it 'returns slug attributes as exhibit' do
        expect(metadata).to be_an Array
        expect(metadata).to include "label" => "Exhibit", "value" => ["lae-d957"]
      end
    end
  end

  describe '#first_title' do
    let(:resource) { FactoryBot.create_for_repository(:scanned_resource, title: ["There and back again", "A hobbit's tale"]) }

    it 'returns the first title' do
      expect(resource.decorate.first_title).to eq "There and back again"
    end
  end

  describe '#merged_titles' do
    let(:resource) { FactoryBot.create_for_repository(:scanned_resource, title: ["There and back again", "A hobbit's tale"]) }

    it 'returns a one-line title string' do
      expect(resource.decorate.merged_titles).to eq "There and back again; A hobbit's tale"
    end
  end

  describe '#titles' do
    let(:resource) { FactoryBot.create_for_repository(:scanned_resource, title: ["There and back again", "A hobbit's tale"]) }

    it 'returns the title array' do
      expect(resource.decorate.titles).to eq ["There and back again", "A hobbit's tale"]
    end
  end

  describe '#member_of_collections_value' do
    let(:collection) { FactoryBot.create_for_repository(:collection, title: 'My Nietzsche Collection') }
    let(:resource) do
      FactoryBot.create_for_repository(
        :scanned_resource,
        title: ["Menschliches, Allzumenschliches", "Ein Buch für freie Geister"],
        member_of_collection_ids: collection.id
      )
    end

    it 'returns the titles of collections' do
      expect(resource.decorate.iiif_metadata).to include('label' => 'Member Of Collections', 'value' => ['My Nietzsche Collection'])
    end
  end

  describe 'manifestable_state?' do
    describe 'for resources without workflows' do
      let(:resource) { FactoryBot.build(:ephemera_term) }
      it 'defaults to true' do
        expect(resource.decorate.manifestable_state?).to eq true
      end
    end

    describe 'a resource with manifestable workflow state' do
      it 'returns true' do
        expect(resource.decorate.manifestable_state?).to eq true
      end
    end

    describe 'a resource with non-manifestable workflow state' do
      it 'returns false' do
        resource.state = ['metadata_review']
        expect(resource.decorate.manifestable_state?).to eq false
      end
    end
  end

  describe 'public_readable_state?' do
    describe 'for resources without workflows' do
      let(:resource) { FactoryBot.build(:ephemera_term) }
      it 'defaults to true' do
        expect(resource.decorate.public_readable_state?).to eq true
      end
    end

    describe 'a resource with public-readable workflow state' do
      it 'returns true' do
        expect(resource.decorate.public_readable_state?).to eq true
      end
    end

    describe 'a resource with non-public-readable workflow state' do
      it 'returns false' do
        resource.state = ['pending']
        expect(resource.decorate.public_readable_state?).to eq false
      end
    end
  end

  describe '#form_input_values' do
    let(:resource) { FactoryBot.build(:scanned_resource, title: "Архипела́г ГУЛА́Г") }
    it 'generates OpenStruct Objects for select form field values' do
      expect(resource.decorate.form_input_values).to be_an OpenStruct
      expect(resource.decorate.form_input_values.title).to eq 'Архипела́г ГУЛА́Г'
      expect(resource.decorate.form_input_values.id).to eq resource.id.to_s
    end
  end
end
