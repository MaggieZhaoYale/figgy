# frozen_string_literal: true
class CharacterizationJob < ApplicationJob
  delegate :query_service, to: :metadata_adapter

  # @param file_set_id [string] stringified Valkyrie id
  def perform(file_set_id)
    file_set = query_service.find_by(id: Valkyrie::ID.new(file_set_id))
    metadata_adapter.persister.buffer_into_index do |buffered_adapter|
      Valkyrie::Derivatives::FileCharacterizationService.for(file_node: file_set, persister: buffered_adapter.persister).characterize
    end
    CreateDerivativesJob.set(queue: queue_name).perform_later(file_set_id)
  end

  def metadata_adapter
    Valkyrie::MetadataAdapter.find(:indexing_persister)
  end
end
