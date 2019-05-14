# frozen_string_literal: true

class ChangeSetPersister
  class PreserveResource
    attr_reader :change_set_persister, :change_set, :post_save_resource
    delegate :metadata_adapter, to: :change_set_persister

    def initialize(change_set_persister:, change_set:, post_save_resource: nil)
      @change_set = change_set
      @change_set_persister = change_set_persister
      @post_save_resource = post_save_resource
    end

    def run
      Preserver.for(change_set: change_set.class.new(post_save_resource), change_set_persister: change_set_persister).preserve!
    end
  end
end