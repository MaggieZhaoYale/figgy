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
      it "returns undecorated scanned_resource members" do
        member = FactoryBot.create_for_repository(:scanned_resource)
        resource = FactoryBot.create_for_repository(:scanned_resource, member_ids: member.id)

        wayfinder = described_class.for(resource)

        expect(wayfinder.scanned_resources.map(&:id)).to eq [member.id]
        expect(wayfinder.scanned_resources.map(&:class)).to eq [ScannedResource]
      end
    end

    describe "#decorated_scanned_resource members" do
      it "returns decorated scanned_resources" do
        member = FactoryBot.create_for_repository(:scanned_resource)
        resource = FactoryBot.create_for_repository(:scanned_resource, member_ids: member.id)

        wayfinder = described_class.for(resource)

        expect(wayfinder.decorated_scanned_resources.map(&:id)).to eq [member.id]
        expect(wayfinder.decorated_scanned_resources.map(&:class)).to eq [ScannedResourceDecorator]
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
  end
  context "when given an ephemera box" do
    describe "#ephemera_folders" do
      it "returns undecorated ephemera_folder members" do
        member = FactoryBot.create_for_repository(:ephemera_folder)
        member2 = FactoryBot.create_for_repository(:scanned_resource)
        resource = FactoryBot.create_for_repository(:ephemera_box, member_ids: [member.id, member2.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.ephemera_folders.map(&:id)).to eq [member.id]
        expect(wayfinder.ephemera_folders.map(&:class)).to eq [EphemeraFolder]
      end
    end

    describe "#decorated_ephemera_folders" do
      it "returns decorated ephemera_folder members" do
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
  end
  context "when given an ephemera folder" do
    describe "#ephemera_projects" do
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
  end

  context "when given an ArchivalMediaCollection" do
    describe "#media_resources" do
      it "returns all media resource members" do
        collection = FactoryBot.create_for_repository(:archival_media_collection)
        FactoryBot.create_for_repository(:media_resource, member_of_collection_ids: [collection.id])
        FactoryBot.create_for_repository(:media_resource, member_of_collection_ids: [collection.id])
        FactoryBot.create_for_repository(:scanned_resource, member_of_collection_ids: [collection.id])

        wayfinder = described_class.for(collection)

        expect(wayfinder.media_resources.size).to eq 2
        expect(wayfinder.media_resources.map(&:class).uniq).to eq [MediaResource]
      end
    end
  end

  context "when given an EphemeraField" do
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
  end
  context "when given an EphemeraProject" do
    describe "#ephemera_boxes" do
      it "returns all box members undecorated without accessing members for a project" do
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

  context "when given a RasterResource" do
    describe "#collections" do
      it "returns all collections it's a member of" do
        collection = FactoryBot.create_for_repository(:collection)
        resource = FactoryBot.create_for_repository(:raster_resource, member_of_collection_ids: collection.id)

        wayfinder = described_class.for(resource)

        expect(wayfinder.collections.map(&:id)).to eq [collection.id]
        expect(wayfinder.collections.map(&:class)).to eq [Collection]
        expect(wayfinder.decorated_collections.map(&:class)).to eq [CollectionDecorator]
      end
    end

    describe "#decorated_file_sets" do
      it "returns all file sets as decorated resources" do
        file_set = FactoryBot.create_for_repository(:file_set)
        resource = FactoryBot.create_for_repository(:raster_resource, member_ids: [file_set.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.decorated_file_sets.map(&:id)).to eq [file_set.id]
        expect(wayfinder.decorated_file_sets.map(&:class).uniq).to eq [FileSetDecorator]
      end
    end

    describe "geo_members" do
      it "returns all file sets which have a raster format" do
        file_set1 = FactoryBot.create_for_repository(:geo_raster_file_set)
        file_set2 = FactoryBot.create_for_repository(:geo_metadata_file_set)
        resource = FactoryBot.create_for_repository(:raster_resource, member_ids: [file_set1.id, file_set2.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.geo_members.map(&:id)).to eq [file_set1.id]
        expect(wayfinder.geo_members.map(&:class).uniq).to eq [FileSet]
      end
    end

    describe "geo_metadata_members" do
      it "returns all file sets which have a metadata format" do
        file_set1 = FactoryBot.create_for_repository(:geo_raster_file_set)
        file_set2 = FactoryBot.create_for_repository(:geo_metadata_file_set)
        resource = FactoryBot.create_for_repository(:raster_resource, member_ids: [file_set1.id, file_set2.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.geo_metadata_members.map(&:id)).to eq [file_set2.id]
        expect(wayfinder.geo_metadata_members.map(&:class).uniq).to eq [FileSet]
      end
    end

    describe "#raster_resources" do
      it "returns all child raster resources" do
        child = FactoryBot.create_for_repository(:raster_resource)
        dummy = FactoryBot.create_for_repository(:file_set)
        parent = FactoryBot.create_for_repository(:raster_resource, member_ids: [child.id, dummy.id])

        wayfinder = described_class.for(parent)

        expect(wayfinder.raster_resources.map(&:id)).to eq [child.id]
        expect(wayfinder.raster_resources.map(&:class)).to eq [RasterResource]
        expect(wayfinder.decorated_raster_resources.map(&:id)).to eq [child.id]
        expect(wayfinder.decorated_raster_resources.map(&:class)).to eq [RasterResourceDecorator]
      end
    end

    describe "#raster_resource_parents" do
      it "returns all parents which are raster resources" do
        child = FactoryBot.create_for_repository(:raster_resource)
        parent = FactoryBot.create_for_repository(:raster_resource, member_ids: [child.id])
        FactoryBot.create_for_repository(:scanned_resource, member_ids: [child.id])

        wayfinder = described_class.for(child)

        expect(wayfinder.raster_resource_parents.map(&:id)).to eq [parent.id]
        expect(wayfinder.raster_resource_parents.map(&:class)).to eq [RasterResource]
        expect(wayfinder.decorated_raster_resource_parents.map(&:id)).to eq [parent.id]
        expect(wayfinder.decorated_raster_resource_parents.map(&:class)).to eq [RasterResourceDecorator]
      end
    end

    describe "#scanned_map_parents" do
      it "returns all parents which are scanned maps" do
        child = FactoryBot.create_for_repository(:raster_resource)
        parent = FactoryBot.create_for_repository(:scanned_map, member_ids: [child.id])
        FactoryBot.create_for_repository(:scanned_resource, member_ids: [child.id])

        wayfinder = described_class.for(child)

        expect(wayfinder.scanned_map_parents.map(&:id)).to eq [parent.id]
        expect(wayfinder.scanned_map_parents.map(&:class)).to eq [ScannedMap]
        expect(wayfinder.decorated_scanned_map_parents.map(&:id)).to eq [parent.id]
        expect(wayfinder.decorated_scanned_map_parents.map(&:class)).to eq [ScannedMapDecorator]
      end
    end

    describe "#vector_resources" do
      it "returns all vector resource members" do
        child = FactoryBot.create_for_repository(:vector_resource)
        dummy = FactoryBot.create_for_repository(:file_set)
        parent = FactoryBot.create_for_repository(:raster_resource, member_ids: [child.id, dummy.id])

        wayfinder = described_class.for(parent)

        expect(wayfinder.vector_resources.map(&:id)).to eq [child.id]
        expect(wayfinder.vector_resources.map(&:class)).to eq [VectorResource]
        expect(wayfinder.decorated_vector_resources.map(&:id)).to eq [child.id]
        expect(wayfinder.decorated_vector_resources.map(&:class)).to eq [VectorResourceDecorator]
      end
    end
  end

  context "when given a scanned map" do
    describe "#collections" do
      it "returns all collections it's a member of" do
        collection = FactoryBot.create_for_repository(:collection)
        resource = FactoryBot.create_for_repository(:scanned_map, member_of_collection_ids: collection.id)

        wayfinder = described_class.for(resource)

        expect(wayfinder.collections.map(&:id)).to eq [collection.id]
        expect(wayfinder.collections.map(&:class)).to eq [Collection]
        expect(wayfinder.decorated_collections.map(&:class)).to eq [CollectionDecorator]
      end
    end

    describe "#file_sets" do
      it "returns all file set members" do
        scanned_map = FactoryBot.create_for_repository(:scanned_map)
        file_set = FactoryBot.create_for_repository(:file_set)
        resource = FactoryBot.create_for_repository(:scanned_map, member_ids: [file_set.id, scanned_map.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.file_sets.map(&:id)).to eq [file_set.id]
        expect(wayfinder.file_sets.map(&:class)).to eq [FileSet]
        expect(wayfinder.decorated_file_sets.map(&:id)).to eq [file_set.id]
        expect(wayfinder.decorated_file_sets.map(&:class)).to eq [FileSetDecorator]
      end
    end

    describe "#geo_image_members" do
      it "returns all geo image members" do
        file_set = FactoryBot.create_for_repository(:geo_image_file_set)
        file_set2 = FactoryBot.create_for_repository(:geo_metadata_file_set)
        scanned_map = FactoryBot.create_for_repository(:scanned_map, member_ids: [file_set.id, file_set2.id])

        wayfinder = described_class.for(scanned_map)

        expect(wayfinder.geo_image_members.map(&:id)).to eq [file_set.id]
        expect(wayfinder.geo_image_members.map(&:class)).to eq [FileSet]
      end
    end

    describe "#geo_metadata_members" do
      it "returns all geo metadata members" do
        file_set = FactoryBot.create_for_repository(:geo_image_file_set)
        file_set2 = FactoryBot.create_for_repository(:geo_metadata_file_set)
        scanned_map = FactoryBot.create_for_repository(:scanned_map, member_ids: [file_set.id, file_set2.id])

        wayfinder = described_class.for(scanned_map)

        expect(wayfinder.geo_metadata_members.map(&:id)).to eq [file_set2.id]
        expect(wayfinder.geo_metadata_members.map(&:class)).to eq [FileSet]
      end
    end

    describe "#raster_resources" do
      it "returns all raster resource members" do
        raster_resource = FactoryBot.create_for_repository(:raster_resource)
        child_map = FactoryBot.create_for_repository(:scanned_map)
        scanned_map = FactoryBot.create_for_repository(:scanned_map, member_ids: [raster_resource.id, child_map.id])

        wayfinder = described_class.for(scanned_map)

        expect(wayfinder.raster_resources.map(&:id)).to eq [raster_resource.id]
        expect(wayfinder.raster_resources.map(&:class)).to eq [RasterResource]
        expect(wayfinder.decorated_raster_resources.map(&:id)).to eq [raster_resource.id]
        expect(wayfinder.decorated_raster_resources.map(&:class)).to eq [RasterResourceDecorator]
      end
    end

    describe "#scanned_maps" do
      it "returns all scanned map members" do
        raster_resource = FactoryBot.create_for_repository(:raster_resource)
        child_map = FactoryBot.create_for_repository(:scanned_map)
        scanned_map = FactoryBot.create_for_repository(:scanned_map, member_ids: [raster_resource.id, child_map.id])

        wayfinder = described_class.for(scanned_map)

        expect(wayfinder.scanned_maps.map(&:id)).to eq [child_map.id]
        expect(wayfinder.scanned_maps.map(&:class)).to eq [ScannedMap]
        expect(wayfinder.decorated_scanned_maps.map(&:id)).to eq [child_map.id]
        expect(wayfinder.decorated_scanned_maps.map(&:class)).to eq [ScannedMapDecorator]
      end
    end

    describe "#scanned_map_parents" do
      it "returns all parents which are scanned maps" do
        child = FactoryBot.create_for_repository(:scanned_map)
        parent = FactoryBot.create_for_repository(:scanned_map, member_ids: [child.id])
        FactoryBot.create_for_repository(:raster_resource, member_ids: [child.id])

        wayfinder = described_class.for(child)

        expect(wayfinder.scanned_map_parents.map(&:id)).to eq [parent.id]
        expect(wayfinder.scanned_map_parents.map(&:class)).to eq [ScannedMap]
        expect(wayfinder.decorated_scanned_map_parents.map(&:id)).to eq [parent.id]
        expect(wayfinder.decorated_scanned_map_parents.map(&:class)).to eq [ScannedMapDecorator]
      end
    end
  end

  context "when given a simple resource" do
    describe "#members" do
      it "returns all members" do
        child = FactoryBot.create_for_repository(:file_set)
        child_resource = FactoryBot.create_for_repository(:simple_resource)
        resource = FactoryBot.create_for_repository(:simple_resource, member_ids: [child.id, child_resource.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.members.map(&:id)).to eq [child.id, child_resource.id]
        expect(wayfinder.members.map(&:class)).to eq [FileSet, SimpleResource]
        expect(wayfinder.decorated_members.map(&:id)).to eq [child.id, child_resource.id]
        expect(wayfinder.decorated_members.map(&:class)).to eq [FileSetDecorator, SimpleResourceDecorator]
      end
    end
    describe "#file_sets" do
      it "returns all file sets" do
        child = FactoryBot.create_for_repository(:file_set)
        child_resource = FactoryBot.create_for_repository(:simple_resource)
        resource = FactoryBot.create_for_repository(:simple_resource, member_ids: [child.id, child_resource.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.file_sets.map(&:id)).to eq [child.id]
        expect(wayfinder.file_sets.map(&:class)).to eq [FileSet]
        expect(wayfinder.decorated_file_sets.map(&:id)).to eq [child.id]
        expect(wayfinder.decorated_file_sets.map(&:class)).to eq [FileSetDecorator]
      end
    end
    describe "#simple_resources" do
      it "returns all simple resource members" do
        child = FactoryBot.create_for_repository(:file_set)
        child_resource = FactoryBot.create_for_repository(:simple_resource)
        resource = FactoryBot.create_for_repository(:simple_resource, member_ids: [child.id, child_resource.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.simple_resources.map(&:id)).to eq [child_resource.id]
        expect(wayfinder.simple_resources.map(&:class)).to eq [SimpleResource]
        expect(wayfinder.decorated_simple_resources.map(&:id)).to eq [child_resource.id]
        expect(wayfinder.decorated_simple_resources.map(&:class)).to eq [SimpleResourceDecorator]
      end
    end
  end

  context "when given a vector resource" do
    describe "#collections" do
      it "returns all collections it's a member of" do
        collection = FactoryBot.create_for_repository(:collection)
        resource = FactoryBot.create_for_repository(:vector_resource, member_of_collection_ids: collection.id)

        wayfinder = described_class.for(resource)

        expect(wayfinder.collections.map(&:id)).to eq [collection.id]
        expect(wayfinder.collections.map(&:class)).to eq [Collection]
        expect(wayfinder.decorated_collections.map(&:class)).to eq [CollectionDecorator]
      end
    end
    describe "#members" do
      it "returns all members" do
        child = FactoryBot.create_for_repository(:geo_metadata_file_set)
        child2 = FactoryBot.create_for_repository(:geo_vector_file_set)
        child_resource = FactoryBot.create_for_repository(:vector_resource)
        resource = FactoryBot.create_for_repository(:vector_resource, member_ids: [child.id, child2.id, child_resource.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.members.map(&:id)).to eq [child.id, child2.id, child_resource.id]
        expect(wayfinder.members.map(&:class)).to eq [FileSet, FileSet, VectorResource]
        expect(wayfinder.decorated_members.map(&:id)).to eq [child.id, child2.id, child_resource.id]
        expect(wayfinder.decorated_members.map(&:class)).to eq [FileSetDecorator, FileSetDecorator, VectorResourceDecorator]
      end
    end
    describe "#file_sets" do
      it "returns all file sets" do
        child = FactoryBot.create_for_repository(:geo_metadata_file_set)
        child2 = FactoryBot.create_for_repository(:geo_vector_file_set)
        child_resource = FactoryBot.create_for_repository(:vector_resource)
        resource = FactoryBot.create_for_repository(:vector_resource, member_ids: [child.id, child2.id, child_resource.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.file_sets.map(&:id)).to eq [child.id, child2.id]
        expect(wayfinder.file_sets.map(&:class)).to eq [FileSet, FileSet]
        expect(wayfinder.decorated_file_sets.map(&:id)).to eq [child.id, child2.id]
        expect(wayfinder.decorated_file_sets.map(&:class)).to eq [FileSetDecorator, FileSetDecorator]
      end
    end

    describe "#geo_vector_members" do
      it "returns all vector mime-type filesets" do
        child = FactoryBot.create_for_repository(:geo_metadata_file_set)
        child2 = FactoryBot.create_for_repository(:geo_vector_file_set)
        child_resource = FactoryBot.create_for_repository(:vector_resource)
        resource = FactoryBot.create_for_repository(:vector_resource, member_ids: [child.id, child2.id, child_resource.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.geo_vector_members.map(&:id)).to eq [child2.id]
        expect(wayfinder.geo_vector_members.map(&:class)).to eq [FileSet]
      end
    end
    describe "#geo_metadata_members" do
      it "returns all metadata mime-type filesets" do
        child = FactoryBot.create_for_repository(:geo_metadata_file_set)
        child2 = FactoryBot.create_for_repository(:geo_vector_file_set)
        child_resource = FactoryBot.create_for_repository(:vector_resource)
        resource = FactoryBot.create_for_repository(:vector_resource, member_ids: [child.id, child2.id, child_resource.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.geo_metadata_members.map(&:id)).to eq [child.id]
        expect(wayfinder.geo_metadata_members.map(&:class)).to eq [FileSet]
      end
    end
    describe "#vector_resources" do
      it "returns all vector resource members" do
        child = FactoryBot.create_for_repository(:geo_metadata_file_set)
        child2 = FactoryBot.create_for_repository(:geo_vector_file_set)
        child_resource = FactoryBot.create_for_repository(:vector_resource)
        resource = FactoryBot.create_for_repository(:vector_resource, member_ids: [child.id, child2.id, child_resource.id])

        wayfinder = described_class.for(resource)

        expect(wayfinder.vector_resources.map(&:id)).to eq [child_resource.id]
        expect(wayfinder.vector_resources.map(&:class)).to eq [VectorResource]
        expect(wayfinder.decorated_vector_resources.map(&:id)).to eq [child_resource.id]
        expect(wayfinder.decorated_vector_resources.map(&:class)).to eq [VectorResourceDecorator]
      end
    end
    describe "#raster_resource_parents" do
      it "returns all parents which are raster resources" do
        child = FactoryBot.create_for_repository(:vector_resource)
        raster_parent = FactoryBot.create_for_repository(:raster_resource, member_ids: [child.id])
        FactoryBot.create_for_repository(:vector_resource, member_ids: [child.id])

        wayfinder = described_class.for(child)

        expect(wayfinder.raster_resource_parents.map(&:id)).to eq [raster_parent.id]
        expect(wayfinder.raster_resource_parents.map(&:class)).to eq [RasterResource]
        expect(wayfinder.decorated_raster_resource_parents.map(&:id)).to eq [raster_parent.id]
        expect(wayfinder.decorated_raster_resource_parents.map(&:class)).to eq [RasterResourceDecorator]
      end
    end
    describe "#vector_resource_parents" do
      it "returns all parents which are vector resources" do
        child = FactoryBot.create_for_repository(:vector_resource)
        FactoryBot.create_for_repository(:raster_resource, member_ids: [child.id])
        vector_parent = FactoryBot.create_for_repository(:vector_resource, member_ids: [child.id])

        wayfinder = described_class.for(child)

        expect(wayfinder.vector_resource_parents.map(&:id)).to eq [vector_parent.id]
        expect(wayfinder.vector_resource_parents.map(&:class)).to eq [VectorResource]
        expect(wayfinder.decorated_vector_resource_parents.map(&:id)).to eq [vector_parent.id]
        expect(wayfinder.decorated_vector_resource_parents.map(&:class)).to eq [VectorResourceDecorator]
      end
    end
  end
  context "when given a file set" do
    describe "#members" do
      it "returns an empty array" do
        file_set = FactoryBot.create_for_repository(:file_set)

        wayfinder = described_class.for(file_set)

        expect(wayfinder.members).to eq []
        expect(wayfinder.decorated_members).to eq []
      end
    end
  end
end