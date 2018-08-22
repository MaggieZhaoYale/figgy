# frozen_string_literal: true
class IngestMETSJob < ApplicationJob
  attr_reader :mets

  # @param [String] mets_file Filename of a METS file to ingest
  # @param [User] user User to ingest as
  def perform(mets_file, user, import_mods = false)
    logger.info "Ingesting METS #{mets_file}"
    @mets = METSDocument::Factory.new(mets_file).new
    @user = user
    @import_mods = import_mods
    change_set_persister.buffer_into_index do |buffered_persister|
      Ingester.for(mets: @mets, user: @user, change_set_persister: buffered_persister, import_mods: @import_mods).ingest
    end
  end

  def change_set_persister
    @change_set_persister ||= ChangeSetPersister.new(metadata_adapter: metadata_adapter,
                                                     storage_adapter: storage_adapter,
                                                     queue: queue_name)
  end

  def metadata_adapter
    Valkyrie::MetadataAdapter.find(:indexing_persister)
  end

  def storage_adapter
    Valkyrie::StorageAdapter.find(:disk_via_copy)
  end

  class Ingester
    delegate :metadata_adapter, to: :change_set_persister
    delegate :query_service, to: :metadata_adapter
    def self.for(mets:, user:, change_set_persister:, import_mods:)
      if mets.multi_volume?
        HierarchicalIngester.new(mets: mets, user: user, change_set_persister: change_set_persister, import_mods: import_mods)
      else
        new(mets: mets, user: user, change_set_persister: change_set_persister, import_mods: import_mods)
      end
    end

    attr_reader :mets, :user, :change_set_persister
    # @param [METSDocument] mets
    # @param [User] user
    # @param [ChangeSetPersister] change_set_persister
    def initialize(mets:, user:, change_set_persister:, import_mods: false)
      @mets = mets
      @user = user
      @change_set_persister = change_set_persister
      @import_mods = import_mods
    end

    def import_mods?
      @import_mods
    end

    # Ingest the resource using a METS Document object
    # @return [ScannedResource] the persisted resource
    def ingest
      # Only import the MODS metadata from the METS Document if a MARC record is
      #   not provided
      change_set.source_metadata_identifier = mets.bib_id unless mets.bib_id.blank?
      change_set.title = mets.label
      change_set.files = files.to_a
      change_set.member_of_collection_ids = [find_or_create_collection(mets.collection_slug)] if mets.respond_to?(:collection_slug)
      persisted = change_set_persister.save(change_set: change_set)
      files.each_with_index do |file, index|
        mets_to_repo_map[file.id.to_s] = persisted.member_ids[index]
      end
      logical_persisted = assign_logical_structure(persisted)
      assign_attributes(logical_persisted) if import_mods?
      logical_persisted
    end

    # Assigns the logical structure used to generate the IIIF Presentation Manifest
    # @param [ScannedResource] the resource being modified
    # @return [ScannedResource] the persisted resource with the logical structure assigned
    def assign_logical_structure(resource)
      new_change_set = DynamicChangeSet.new(resource)
      new_change_set.logical_structure = [{ label: "Main Structure", nodes: map_fileids(mets.structure)[:nodes] }]
      change_set_persister.save(change_set: new_change_set)
    end

    # Assigns the metadata attributes from the METS Document (which are not
    #   featured in the bib. source record
    # @param [ScannedResource] the resource being modified
    # @return [ScannedResource] the persisted resource with the logical structure assigned
    def assign_attributes(resource)
      new_change_set = DynamicChangeSet.new(resource)
      new_change_set.prepopulate!
      return resource unless new_change_set.validate(mets.attributes)
      new_change_set.sync
      change_set_persister.save(change_set: new_change_set)
    end

    # Generate Hashes for each file linked to the described resource in the
    #   METS Document
    # @return [Array<Hash>]
    def files
      mets.files.lazy.map do |file|
        mets.decorated_file(file)
      end
    end

    # Finds an existing or creates a new Collection for the imported Resource
    # @param [String] slug
    # @return [Valkyrie::ID]
    def find_or_create_collection(slug)
      existing_collections = query_service.custom_queries.find_by_string_property(property: :slug, value: slug)
      return existing_collections.first.id unless existing_collections.to_a.empty?

      new_collection = Collection.new(title: slug, slug: slug)
      new_collection_change_set = CollectionChangeSet.new(new_collection)
      collection = change_set_persister.save(change_set: new_collection_change_set)
      collection.id
    end

    # Provide the resource class used for ingesting Resources using a METS Document
    # @return [Class]
    def resource_klass
      ScannedResource
    end

    # Construct the ChangeSet object for the new resource
    # @return [ChangeSet]
    def change_set
      @change_set ||=
        begin
          DynamicChangeSet.new(resource_klass.new)
        end
    end

    # Map a Hash recursively keyed to each FileSet ID
    # @param [Hash] hsh source of Hash values (usually generated from METSDocument#structure)
    # @return [Hash]
    def map_fileids(hsh)
      hsh.each do |k, v|
        hsh[k] = v.each { |node| map_fileids(node) } if k == :nodes
        hsh[k] = mets_to_repo_map[v] if k == :proxy
      end
    end

    # Generate the internal Hash used to store the mapping
    # @return [Hash]
    def mets_to_repo_map
      @mets_to_repo_map ||= {}
    end
  end

  class HierarchicalIngester < Ingester
    def ingest
      change_set.source_metadata_identifier = mets.bib_id
      mets.volume_ids.each do |volume_id|
        volume_mets = VolumeMets.new(parent_mets: mets, volume_id: volume_id)
        volume = Ingester.new(mets: volume_mets, user: user, change_set_persister: change_set_persister, import_mods: import_mods?).ingest
        change_set.member_ids = change_set.member_ids + [volume.id]
      end
      change_set_persister.save(change_set: change_set)
    end
  end

  # Class modeling the METS Document for child volumes within multi-volume
  #   works
  class VolumeMets
    attr_reader :parent_mets, :volume_id
    delegate :decorated_file, to: :parent_mets

    # @param [METS::Document] parent_mets
    # @param [String] volume_id
    def initialize(parent_mets:, volume_id:)
      @parent_mets = parent_mets
      @volume_id = volume_id
    end

    # Access the bib. ID
    # @see METSDocument#bib_id
    # (There are no bib. IDs for child volumes, these are retrieved from the
    #   parent resource)
    # @return [nil]
    def bib_id
      nil
    end

    # Retrieve the information for the files from the METS for the parent
    #   resource
    # @see METSDocument#files
    # @return [Hash<Array>]
    def files
      parent_mets.files_for_volume(volume_id)
    end

    # Retrieve the structure from the METS for the parent resource
    # @see MetsStructure#structure_for_volume
    # @return [Hash]
    def structure
      parent_mets.structure_for_volume(volume_id)
    end

    # Retrieve the label for the volume
    # @see METSDocument#label_for_volume
    # @return [String]
    def label
      parent_mets.label_for_volume(volume_id)
    end

    # Merge the metadata attributes with those of the parent resource
    # @see METSDocument#attributes
    # @return [Hash]
    def attributes
      parent_mets.attributes.merge(title: [label])
    end
  end
end
