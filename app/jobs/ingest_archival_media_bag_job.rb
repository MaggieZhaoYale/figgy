# frozen_string_literal: true
class IngestArchivalMediaBagJob < ApplicationJob
  BARCODE_WITH_PART_REGEX = /(\d{14}_\d+)_.*/

  def perform(collection_component:, bag_path:, user:)
    bag_path = Pathname.new(bag_path.to_s)
    bag = ArchivalMediaBagParser.new(path: bag_path)
    changeset_persister.buffer_into_index do |buffered_persister|
      amc = find_or_create_amc(collection_component)
      Ingester.new(collection: amc, bag: bag, user: user, changeset_persister: buffered_persister).ingest
    end
  end

  private

    def find_or_create_amc(component_id)
      existing_amc = metadata_adapter.query_service.custom_queries
                                     .find_by_string_property(property: :source_metadata_identifier, value: component_id)
                                     .select { |r| r.is_a? ArchivalMediaCollection }.first
      return existing_amc unless existing_amc.nil?
      change_set = DynamicChangeSet.new(ArchivalMediaCollection.new)
      change_set.validate(source_metadata_identifier: component_id)
      change_set.sync
      changeset_persister.save(change_set: change_set)
    end

    def changeset_persister
      @changeset_persister ||= PlumChangeSetPersister.new(metadata_adapter: metadata_adapter,
                                                          storage_adapter: storage_adapter,
                                                          queue: queue_name)
    end

    def metadata_adapter
      Valkyrie::MetadataAdapter.find(:indexing_persister)
    end

    def storage_adapter
      Valkyrie::StorageAdapter.find(:disk_via_copy)
    end

    # get all the data files, group them in file sets (master (original_file), intermediate (for download), access)
    class ArchivalMediaBagParser
      attr_reader :path, :audio_files, :file_groups, :component_groups
      def initialize(path:)
        @path = path
        @file_groups = {}
        @component_groups = {}
      end

      # group all the files in the bag by barcode_with_part
      def file_groups
        return @file_groups unless @file_groups.empty?
        audio_files.each do |audio_file|
          @file_groups[audio_file.barcode_with_part] = @file_groups.fetch(audio_file.barcode_with_part, []).append(audio_file)
        end
        @file_groups
      end

      # file_groups in groups by component id
      def component_groups(component_dict)
        return @component_groups unless @component_groups.empty?
        file_groups.keys.each do |barcode_with_part|
          cid = component_dict.lookup(barcode_with_part)
          @component_groups[cid] = @component_groups.fetch(cid, []).append(barcode_with_part)
        end
        @component_groups
      end

      private

        # create an AudioPath object for each audio file
        def audio_files
          @audio_files ||= path.join("data").each_child.select { |file| [".wav", ".mp3"].include? file.extname }.map { |file| IngestableAudioFile.new(path: file) }
        end
    end

    # Decorates the Pathname with some convenience parsing methods
    # Provides methods needed by FileMetadata.for
    class IngestableAudioFile
      attr_reader :path, :barcode_with_part
      def initialize(path:)
        @path = path
      end

      def original_filename
        path.split.last
      end

      def mime_type
        if master? || intermediate?
          "audio/wav"
        else
          "audio/mpeg"
        end
      end
      alias content_type mime_type

      def use
        if master?
          Valkyrie::Vocab::PCDMUse.PreservationMasterFile
        elsif intermediate?
          Valkyrie::Vocab::PCDMUse.IntermediateFile
        elsif access?
          Valkyrie::Vocab::PCDMUse.ServiceFile
        end
      end

      def master?
        path.to_s.end_with?("_pm.wav")
      end

      def intermediate?
        path.to_s.end_with?("_i.wav")
      end

      def access?
        path.to_s.end_with?("_a.mp3")
      end

      def barcode_with_part
        @barcode_with_part ||= BARCODE_WITH_PART_REGEX.match(original_filename.to_s)[1]
      end
    end

    # Wraps a hash of component_id => barcode_with_part
    class BarcodeComponentDict
      attr_reader :collection, :dict
      def initialize(collection)
        @collection = collection
        parse_dict
      end

      def lookup(barcode_with_part)
        @dict[barcode_with_part]
      end

      private

        # query the EAD for filenames, navigates back up to their component IDs
        def parse_dict
          @dict = {}
          barcode_nodes.each do |node|
            @dict[get_barcode_with_part(node)] = get_id(node)
          end
        end

        def xml
          @xml ||= Nokogiri::XML(collection.imported_metadata.first.source_metadata.first).remove_namespaces!
        end

        def barcode_nodes
          xml.xpath('//altformavail/p')
        end

        def get_id(node)
          node.parent.parent.attributes['id'].value
        end

        def get_barcode_with_part(node)
          BARCODE_WITH_PART_REGEX.match(node.content)[1]
        end
    end

    class Ingester
      attr_reader :collection, :bag, :user, :changeset_persister
      def initialize(collection:, bag:, user:, changeset_persister:)
        @collection = collection
        @bag = bag
        @user = user
        @changeset_persister = changeset_persister
      end

      def ingest
        component_groups.each do |cid, sides|
          media_resource = MediaResourceChangeSet.new(find_or_create_media_resource(cid))
          sides.each do |side|
            file_set = create_av_file_set(side)
            media_resource.member_ids += Array.wrap(file_set.id)
            media_resource.sync
          end
          media_resource.member_of_collection_ids += Array.wrap(collection.id)
          media_resource.sync
          changeset_persister.save(change_set: media_resource)
        end
      end

      private

        def component_dict
          @component_dict ||= BarcodeComponentDict.new(collection)
        end

        def component_groups
          @component_groups ||= bag.component_groups(component_dict)
        end

        def create_av_file_set(side)
          file_set = FileSet.new(title: side)
          bag.file_groups[side].each do |file| # this is an IngestableAudioFile object
            node = create_node(file)
            file_set.file_metadata += Array.wrap(node)
          end
          file_set = changeset_persister.save(change_set: FileSetChangeSet.new(file_set))
        end

        def create_node(file)
          attributes = { id: SecureRandom.uuid }
          node = FileMetadata.for(file: file).new(attributes)
          file = storage_adapter.upload(file: file, resource: node, original_filename: file.original_filename)
          node.file_identifiers = node.file_identifiers + [file.id]
          node
        end

        def find_or_create_media_resource(component_id)
          results = query_service.custom_queries.find_by_string_property(property: :source_metadata_identifier, value: component_id)
          return results.first unless results.size.zero?
          MediaResource.new(source_metadata_identifier: component_id)
        end

        def storage_adapter
          Valkyrie::StorageAdapter.find(:disk_via_copy)
        end

        def query_service
          Valkyrie::MetadataAdapter.find(:indexing_persister).query_service
        end
    end

  # end private
end