# frozen_string_literal: true
class NumismaticAccession < Resource
  include Valkyrie::Resource::AccessControls

  attribute :date
  attribute :person
  attribute :firm
  attribute :accession_number, Valkyrie::Types::Int
  attribute :type
  attribute :cost
  attribute :account
  attribute :note
  attribute :private_note
  attribute :thumbnail_id
  attribute :numismatic_citation_ids, Valkyrie::Types::Array

  def title
    ["Accession: #{accession_number}"]
  end
end
