# frozen_string_literal: true
class Preserver::BlindImporter::FileMetadataAdapter
  class QueryService
    delegate :storage_adapter, to: :adapter
    attr_reader :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def find_by(id:)
      file = storage_adapter.find_by(id: storage_id_from_resource_id(id))
      json = JSON.parse(file.read)
      attributes = Valkyrie::Persistence::Shared::JSONValueMapper.new(json).result.symbolize_keys
      fix_file_metadata(Valkyrie::Types::Anything[attributes])
    # Rescue NoMethodError because it's what the GCS shrine adapter is throwing
    # right now when a file isn't found.
    rescue NoMethodError, Valkyrie::StorageAdapter::FileNotFound
      raise Valkyrie::Persistence::ObjectNotFoundError
    end

    def fix_file_metadata(resource)
      return resource unless resource.try(:file_metadata).present?
      resource.file_metadata.map! do |file_metadata|
        file_metadata.file_identifiers.map! do |identifier|
          preservation_location = storage_id_from_resource_id(resource.id, original_filename: original_filename(identifier, file_metadata))
          begin
            storage_adapter.find_by(id: preservation_location).id
          # Rescue NoMethodError because the GCS Shrine Valkyrie adapter has a
          # bug with NotFound not returning right.
          rescue Valkyrie::StorageAdapter::FileNotFound, NoMethodError
            nil
          end
        end.compact!
        file_metadata
      end
      resource.file_metadata = resource.file_metadata.select { |x| x.file_identifiers.present? }
      resource
    end

    def original_filename(identifier, file_metadata)
      original_filename = Pathname.new(identifier.to_s).basename.to_s.split(".")
      "#{original_filename[0]}-#{file_metadata.id}.#{original_filename[1]}"
    end

    def storage_id_from_resource_id(id, original_filename: nil)
      path = storage_adapter.path_generator.generate(
        resource: FileMetadataResource.new(id: id, new_record: false, parents: adapter.parents),
        file: nil,
        original_filename: original_filename || "#{id}.json"
      )
      "#{path_prefix}://#{path}"
    end

    # TODO: I wonder if Valkyrie could provide some method of doing this?
    def path_prefix
      storage_adapter.is_a?(Valkyrie::Storage::Disk) ? "disk" : "shrine"
    end
  end
end
