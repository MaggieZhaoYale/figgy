# frozen_string_literal: true
class PlumChangeSetPersister
  def self.new(metadata_adapter:, storage_adapter:, transaction: false, characterize: true, queue: :default)
    Basic.new(metadata_adapter: metadata_adapter,
              storage_adapter: storage_adapter,
              transaction: transaction,
              characterize: characterize,
              queue: queue,
              handlers: registered_handlers)
  end

  # rubocop:disable Metrics/MethodLength
  def self.registered_handlers
    {
      before_save: [
        ApplyRemoteMetadata,
        CreateFile::Factory.new(file_appender: FileAppender),
        PropagateVisibilityAndState
      ],
      after_save: [
        AppendToParent
      ],
      after_save_commit: [
        PublishMessage::Factory.new(operation: :update)
      ],
      before_delete: [
        CleanupStructure,
        CleanupDerivatives,
        DeleteReferenced::Factory.new(property: :member_of_vocabulary_id),
        DeleteMembers::Factory.new(property: :member_ids),
        CleanupMembership::Factory.new(property: :member_ids),
        CleanupMembership::Factory.new(property: :member_of_collection_ids)
      ],
      after_delete_commit: [
        PublishMessage::Factory.new(operation: :delete)
      ],
      after_commit: [
        Characterize,
        PublishMessage::Factory.new(operation: :create)
      ]
    }
  end
  # rubocop:enable Metrics/MethodLength

  class Basic
    attr_reader :metadata_adapter, :storage_adapter, :created_file_sets, :handlers
    attr_accessor :created_file_sets, :queued_events, :queue
    delegate :persister, :query_service, to: :metadata_adapter
    def initialize(metadata_adapter:, storage_adapter:, transaction: false, characterize: true, queue: :default, handlers: {})
      @metadata_adapter = metadata_adapter
      @storage_adapter = storage_adapter
      @transaction = transaction
      @characterize = characterize
      @handlers = handlers
      @queued_events = []
      @queue = queue
    end

    def registered_handlers
      handlers
    end

    def save(change_set:)
      before_save(change_set: change_set)
      persister.save(resource: change_set.resource).tap do |output|
        after_save(change_set: change_set, updated_resource: output)
        after_save_commit(change_set: change_set, updated_resource: output)
        after_commit
      end
    end

    def delete(change_set:)
      before_delete(change_set: change_set)
      persister.delete(resource: change_set.resource).tap do
        after_delete_commit(change_set: change_set)
        after_commit
      end
    end

    def save_all(change_sets:)
      change_sets.map do |change_set|
        save(change_set: change_set)
      end
    end

    def buffer_into_index
      metadata_adapter.persister.buffer_into_index do |buffered_adapter|
        with(metadata_adapter: buffered_adapter) do |buffered_changeset_persister|
          yield(buffered_changeset_persister)
          @created_file_sets = buffered_changeset_persister.created_file_sets
          self.queued_events = buffered_changeset_persister.queued_events
        end
      end
      queued_events.each(&:run)
      self.queued_events = []
    end

    def transaction?
      @transaction
    end

    def characterize?
      @characterize
    end

    def with(metadata_adapter:)
      yield self.class.new(metadata_adapter: metadata_adapter, storage_adapter: storage_adapter, transaction: true, characterize: @characterize, queue: queue, handlers: handlers)
    end

    def messenger
      @messenger ||= ManifestEventGenerator.new(Figgy.messaging_client)
    end

    private

      def before_save(change_set:)
        registered_handlers.fetch(:before_save, []).each do |handler|
          handler.new(change_set_persister: self, change_set: change_set).run
        end
      end

      def after_save(change_set:, updated_resource:)
        registered_handlers.fetch(:after_save, []).each do |handler|
          handler.new(change_set_persister: self, change_set: change_set, post_save_resource: updated_resource).run
        end
      end

      def after_save_commit(change_set:, updated_resource:)
        registered_handlers.fetch(:after_save_commit, []).each do |handler|
          instance = handler.new(change_set_persister: self, change_set: change_set, post_save_resource: updated_resource)
          if transaction?
            queued_events << instance
          else
            instance.run
          end
        end
      end

      def before_delete(change_set:)
        registered_handlers.fetch(:before_delete, []).each do |handler|
          handler.new(change_set_persister: self, change_set: change_set).run
        end
      end

      def after_delete_commit(change_set:)
        registered_handlers.fetch(:after_delete_commit, []).each do |handler|
          instance = handler.new(change_set_persister: self, change_set: change_set)
          if transaction?
            queued_events << instance
          else
            instance.run
          end
        end
      end

      def after_commit
        registered_handlers.fetch(:after_commit, []).each do |handler|
          instance = handler.new(change_set_persister: self, change_set: nil, created_file_sets: @created_file_sets)
          if transaction?
            queued_events << instance
          else
            instance.run
          end
        end
      end
  end
end
