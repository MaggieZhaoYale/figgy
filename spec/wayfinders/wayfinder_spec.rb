# frozen_string_literal: true
require "rails_helper"

RSpec.describe Wayfinder do
  context "when given a ScannedResource" do
    describe "#members" do
      it "returns undecorated members" do
        member = FactoryBot.create_for_repository(:scanned_resource)
        resource = FactoryBot.create_for_repository(:scanned_resource, member_ids: member.id)

        wayfinder = described_class.for(resource)

        expect(wayfinder.members.map(&:id)).to eq [member.id]
        expect(wayfinder.members.map(&:class)).to eq [ScannedResource]
      end
    end

    describe "#scanned_resources" do
      it "returns undecorated scanned_resources" do
        member = FactoryBot.create_for_repository(:scanned_resource)
        resource = FactoryBot.create_for_repository(:scanned_resource, member_ids: member.id)

        wayfinder = described_class.for(resource)

        expect(wayfinder.scanned_resources.map(&:id)).to eq [member.id]
        expect(wayfinder.scanned_resources.map(&:class)).to eq [ScannedResource]
      end
    end

    describe "#decorated_scanned_resources" do
      it "returns decorated scanned_resources" do
        member = FactoryBot.create_for_repository(:scanned_resource)
        resource = FactoryBot.create_for_repository(:scanned_resource, member_ids: member.id)

        wayfinder = described_class.for(resource)

        expect(wayfinder.decorated_scanned_resources.map(&:id)).to eq [member.id]
        expect(wayfinder.decorated_scanned_resources.map(&:class)).to eq [ScannedResourceDecorator]
      end
    end

    describe "#ephemera_folders" do
      it "returns undecorated ephemera_folders" do
        member = FactoryBot.create_for_repository(:ephemera_folder)
        member2 = FactoryBot.create_for_repository(:scanned_resource)
        resource = FactoryBot.create_for_repository(:ephemera_box, member_ids: [member.id, member2.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.ephemera_folders.map(&:id)).to eq [member.id]
        expect(wayfinder.ephemera_folders.map(&:class)).to eq [EphemeraFolder]
      end
    end

    describe "#decorated_ephemera_folders" do
      it "returns decorated ephemera_folders" do
        member = FactoryBot.create_for_repository(:ephemera_folder)
        member2 = FactoryBot.create_for_repository(:scanned_resource)
        resource = FactoryBot.create_for_repository(:ephemera_box, member_ids: [member.id, member2.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.decorated_ephemera_folders.map(&:id)).to eq [member.id]
        expect(wayfinder.decorated_ephemera_folders.map(&:class)).to eq [EphemeraFolderDecorator]
      end
    end

    describe "#ephemera_folders_count" do
      it "returns the number of member folders" do
        member = FactoryBot.create_for_repository(:ephemera_folder)
        member2 = FactoryBot.create_for_repository(:scanned_resource)
        resource = FactoryBot.create_for_repository(:ephemera_box, member_ids: [member.id, member2.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.ephemera_folders_count).to eq 1
      end
    end

    describe "#ephemera_projects" do
      it "returns all the projects a box is a member of" do
        member = FactoryBot.create_for_repository(:ephemera_box)
        resource = FactoryBot.create_for_repository(:ephemera_project, member_ids: [member.id])

        wayfinder = described_class.for(member)

        expect(wayfinder.ephemera_projects.map(&:id)).to eq [resource.id]
        expect(wayfinder.ephemera_projects.map(&:class).uniq).to eq [EphemeraProject]
      end
      it "returns the project a folder is directly attached to" do
        member = FactoryBot.create_for_repository(:ephemera_folder)
        resource = FactoryBot.create_for_repository(:ephemera_project, member_ids: [member.id])

        wayfinder = described_class.for(member)

        expect(wayfinder.ephemera_projects.map(&:id)).to eq [resource.id]
        expect(wayfinder.ephemera_projects.map(&:class).uniq).to eq [EphemeraProject]
      end
      it "returns the project a box which a folder is attached to is a member of" do
        member = FactoryBot.create_for_repository(:ephemera_folder)
        box = FactoryBot.create_for_repository(:ephemera_box, member_ids: [member.id])
        resource = FactoryBot.create_for_repository(:ephemera_project, member_ids: [box.id])

        wayfinder = described_class.for(member)

        expect(wayfinder.ephemera_projects.map(&:id)).to eq [resource.id]
        expect(wayfinder.ephemera_projects.map(&:class).uniq).to eq [EphemeraProject]
      end
    end

    describe "#decorated_ephemera_projects" do
      it "returns all the projects a box is a member of, decorated" do
        member = FactoryBot.create_for_repository(:ephemera_box)
        resource = FactoryBot.create_for_repository(:ephemera_project, member_ids: [member.id])

        wayfinder = described_class.for(member)

        expect(wayfinder.decorated_ephemera_projects.map(&:id)).to eq [resource.id]
        expect(wayfinder.decorated_ephemera_projects.map(&:class).uniq).to eq [EphemeraProjectDecorator]
      end
    end

    describe "#file_sets" do
      it "returns undecorated FileSets" do
        member = FactoryBot.create_for_repository(:scanned_resource)
        member2 = FactoryBot.create_for_repository(:file_set)
        resource = FactoryBot.create_for_repository(:scanned_resource, member_ids: [member.id, member2.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.file_sets.map(&:id)).to eq [member2.id]
        expect(wayfinder.file_sets.map(&:class)).to eq [FileSet]
      end
    end

    describe "#decorated_file_sets" do
      it "returns decorated FileSets" do
        member = FactoryBot.create_for_repository(:scanned_resource)
        member2 = FactoryBot.create_for_repository(:file_set)
        resource = FactoryBot.create_for_repository(:scanned_resource, member_ids: [member.id, member2.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.decorated_file_sets.map(&:id)).to eq [member2.id]
        expect(wayfinder.decorated_file_sets.map(&:class)).to eq [FileSetDecorator]
      end
    end

    describe "#collections" do
      it "returns undecorated parent collections" do
        collection = FactoryBot.create_for_repository(:collection)
        resource = FactoryBot.create_for_repository(:scanned_resource, member_of_collection_ids: [collection.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.collections.map(&:id)).to eq [collection.id]
        expect(wayfinder.collections.map(&:class)).to eq [Collection]
      end
    end

    describe "#decorated_collections" do
      it "returns decorated parent collections" do
        collection = FactoryBot.create_for_repository(:collection)
        resource = FactoryBot.create_for_repository(:scanned_resource, member_of_collection_ids: [collection.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.decorated_collections.map(&:id)).to eq [collection.id]
        expect(wayfinder.decorated_collections.map(&:class)).to eq [CollectionDecorator]
      end
    end

    describe "#parent" do
      it "returns the undecorated parent" do
        child = FactoryBot.create_for_repository(:scanned_resource)
        parent = FactoryBot.create_for_repository(:scanned_resource, member_ids: [child.id])

        wayfinder = described_class.for(child)

        expect(wayfinder.parent.id).to eq parent.id
        expect(wayfinder.parent.class).to eq ScannedResource
      end
    end

    describe "#decorated_parent" do
      it "returns the decorated parent" do
        child = FactoryBot.create_for_repository(:scanned_resource)
        parent = FactoryBot.create_for_repository(:scanned_resource, member_ids: [child.id])

        wayfinder = described_class.for(child)

        expect(wayfinder.decorated_parent.id).to eq parent.id
        expect(wayfinder.decorated_parent.class).to eq ScannedResourceDecorator
      end
    end

    describe "#parents" do
      it "returns all parents undecorated" do
        child = FactoryBot.create_for_repository(:scanned_resource)
        parent = FactoryBot.create_for_repository(:scanned_resource, member_ids: [child.id])
        parent2 = FactoryBot.create_for_repository(:scanned_resource, member_ids: [child.id])

        wayfinder = described_class.for(child)

        expect(wayfinder.parents.map(&:id)).to contain_exactly parent.id, parent2.id
        expect(wayfinder.parents.map(&:class).uniq).to eq [ScannedResource]
      end
    end

    describe "#decorated_parents" do
      it "returns all parents decorated" do
        child = FactoryBot.create_for_repository(:scanned_resource)
        parent = FactoryBot.create_for_repository(:scanned_resource, member_ids: [child.id])
        parent2 = FactoryBot.create_for_repository(:scanned_resource, member_ids: [child.id])

        wayfinder = described_class.for(child)

        expect(wayfinder.decorated_parents.map(&:id)).to contain_exactly parent.id, parent2.id
        expect(wayfinder.decorated_parents.map(&:class).uniq).to eq [ScannedResourceDecorator]
      end
    end

    describe "#media_resources" do
      it "returns all media resources" do
        collection = FactoryBot.create_for_repository(:archival_media_collection)
        FactoryBot.create_for_repository(:media_resource, member_of_collection_ids: [collection.id])
        FactoryBot.create_for_repository(:media_resource, member_of_collection_ids: [collection.id])
        FactoryBot.create_for_repository(:scanned_resource, member_of_collection_ids: [collection.id])

        wayfinder = described_class.for(collection)

        expect(wayfinder.media_resources.size).to eq 2
        expect(wayfinder.media_resources.map(&:class).uniq).to eq [MediaResource]
      end
    end

    describe "#ephemera_vocabulary" do
      it "returns the vocabulary for an ephemera field" do
        vocabulary = FactoryBot.create_for_repository(:ephemera_vocabulary)
        field = FactoryBot.create_for_repository(:ephemera_field, member_of_vocabulary_id: vocabulary.id)

        wayfinder = described_class.for(field)

        expect(wayfinder.ephemera_vocabulary.id).to eq vocabulary.id
        expect(wayfinder.ephemera_vocabulary.class).to eq EphemeraVocabulary
      end
    end

    describe "#decorated_ephemera_vocabulary" do
      it "returns the vocabulary for an ephemera field decorated" do
        vocabulary = FactoryBot.create_for_repository(:ephemera_vocabulary)
        field = FactoryBot.create_for_repository(:ephemera_field, member_of_vocabulary_id: vocabulary.id)

        wayfinder = described_class.for(field)

        expect(wayfinder.decorated_ephemera_vocabulary.id).to eq vocabulary.id
        expect(wayfinder.decorated_ephemera_vocabulary.class).to eq EphemeraVocabularyDecorator
      end
    end

    describe "#ephemera_box" do
      it "returns the ephemera box for an ephemera folder in a box" do
        folder = FactoryBot.create_for_repository(:ephemera_folder)
        box = FactoryBot.create_for_repository(:ephemera_box, member_ids: folder.id)

        wayfinder = described_class.for(folder)

        expect(wayfinder.ephemera_box.id).to eq box.id
        expect(wayfinder.ephemera_box.class).to eq EphemeraBox
      end
    end

    describe "#decorated_ephemera_box" do
      it "returns the ephemera box for an ephemera folder in a box decorated" do
        folder = FactoryBot.create_for_repository(:ephemera_folder)
        box = FactoryBot.create_for_repository(:ephemera_box, member_ids: folder.id)

        wayfinder = described_class.for(folder)

        expect(wayfinder.decorated_ephemera_box.id).to eq box.id
        expect(wayfinder.decorated_ephemera_box.class).to eq EphemeraBoxDecorator
      end
    end

    describe "#ephemera_boxes" do
      it "returns all box members without accessing members for a project" do
        box = FactoryBot.create_for_repository(:ephemera_box)
        folder = FactoryBot.create_for_repository(:ephemera_folder)
        project = FactoryBot.create_for_repository(:ephemera_project, member_ids: [box.id, folder.id])

        wayfinder = described_class.for(project)
        allow(wayfinder.query_service).to receive(:find_members).and_call_original

        expect(wayfinder.ephemera_boxes.map(&:id)).to eq [box.id]
        expect(wayfinder.ephemera_boxes.map(&:class)).to eq [EphemeraBox]
        expect(wayfinder.query_service).to have_received(:find_members).with(resource: project, model: EphemeraBox)

        expect(wayfinder.decorated_ephemera_boxes.map(&:id)).to eq [box.id]
        expect(wayfinder.decorated_ephemera_boxes.map(&:class)).to eq [EphemeraBoxDecorator]
      end
    end

    describe "#ephemera_folders" do
      it "returns all folder members without accessing members for a project" do
        box = FactoryBot.create_for_repository(:ephemera_box)
        folder = FactoryBot.create_for_repository(:ephemera_folder)
        project = FactoryBot.create_for_repository(:ephemera_project, member_ids: [box.id, folder.id])

        wayfinder = described_class.for(project)
        allow(wayfinder.query_service).to receive(:find_members).and_call_original

        expect(wayfinder.ephemera_folders.map(&:id)).to eq [folder.id]
        expect(wayfinder.ephemera_folders.map(&:class)).to eq [EphemeraFolder]
        expect(wayfinder.query_service).to have_received(:find_members).with(resource: project, model: EphemeraFolder)

        expect(wayfinder.decorated_ephemera_folders.map(&:id)).to eq [folder.id]
        expect(wayfinder.decorated_ephemera_folders.map(&:class)).to eq [EphemeraFolderDecorator]
      end
    end

    describe "#ephemera_fields" do
      it "returns all EphemeraField members without accessing members for a project" do
        box = FactoryBot.create_for_repository(:ephemera_box)
        folder = FactoryBot.create_for_repository(:ephemera_folder)
        field = FactoryBot.create_for_repository(:ephemera_field)
        project = FactoryBot.create_for_repository(:ephemera_project, member_ids: [box.id, folder.id, field.id])

        wayfinder = described_class.for(project)
        allow(wayfinder.query_service).to receive(:find_members).and_call_original

        expect(wayfinder.ephemera_fields.map(&:id)).to eq [field.id]
        expect(wayfinder.ephemera_fields.map(&:class)).to eq [EphemeraField]
        expect(wayfinder.query_service).to have_received(:find_members).with(resource: project, model: EphemeraField)

        expect(wayfinder.decorated_ephemera_fields.map(&:id)).to eq [field.id]
        expect(wayfinder.decorated_ephemera_fields.map(&:class)).to eq [EphemeraFieldDecorator]
      end
    end

    describe "#templates" do
      it "returns templates associated with the EphemeraProject" do
        project = FactoryBot.create_for_repository(:ephemera_project)
        template = FactoryBot.create_for_repository(:template, parent_id: project.id)

        wayfinder = described_class.for(project)

        expect(wayfinder.templates.map(&:id)).to eq [template.id]
        expect(wayfinder.templates.map(&:class)).to eq [Template]

        expect(wayfinder.decorated_templates.map(&:id)).to eq [template.id]
        expect(wayfinder.decorated_templates.map(&:class)).to eq [TemplateDecorator]
      end
    end
  end
end
