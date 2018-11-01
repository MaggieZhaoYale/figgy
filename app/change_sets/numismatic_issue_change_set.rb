# frozen_string_literal: true
class NumismaticIssueChangeSet < ChangeSet
  delegate :human_readable_type, to: :model
  apply_workflow(DraftCompleteWorkflow)

  include VisibilityProperty
  property :artist, multiple: true, required: false, default: []
  property :color, multiple: false, required: false
  property :date_range, multiple: false, required: false
  property :denomination, multiple: false, required: false
  property :department, multiple: false, required: false
  property :description, multiple: false, required: false
  property :edge, multiple: false, required: false
  property :era, multiple: false, required: false
  property :figure, multiple: false, required: false
  property :geographic_origin, multiple: false, required: false
  property :master, multiple: false, required: false
  property :metal, multiple: false, required: false
  property :note, multiple: true, required: false, default: []
  property :object_type, multiple: false, required: false
  property :obverse_attributes, multiple: true, required: false, default: []
  property :obverse_legend, multiple: false, required: false
  property :obverse_type, multiple: false, required: false
  property :orientation, multiple: false, required: false
  property :part, multiple: true, required: false, default: []
  property :place, multiple: false, required: false, default: []
  property :references, multiple: true, required: false, default: []
  property :reverse_attributes, multiple: true, required: false, default: []
  property :reverse_legend, multiple: false, required: false
  property :reverse_type, multiple: false, required: false
  property :ruler, multiple: false, required: false
  property :series, multiple: false, required: false
  property :shape, multiple: false, required: false
  property :subject, multiple: true, required: false, default: []
  property :symbol, multiple: false, required: false
  property :workshop, multiple: false, required: false

  property :read_groups, multiple: true, required: false
  property :depositor, multiple: false, required: false
  property :member_ids, multiple: true, required: false, type: Types::Strict::Array.of(Valkyrie::Types::ID)
  property :member_of_collection_ids, multiple: true, required: false, type: Types::Strict::Array.of(Valkyrie::Types::ID)
  property :pending_uploads, multiple: true, required: false

  property :start_canvas, required: false
  property :viewing_direction, required: false
  property :viewing_hint, multiple: false, required: false, default: "individuals"

  property :rights_statement, multiple: false, required: true, default: "http://rightsstatements.org/vocab/NKC/1.0/", type: ::Types::URI
  property :rights_note, multiple: false, required: false

  # Virtual Attributes
  property :files, virtual: true, multiple: true, required: false

  validates_with CollectionValidator
  validates_with MemberValidator
  validates_with RightsStatementValidator
  validates_with StateValidator
  validates_with ViewingDirectionValidator
  validates_with ViewingHintValidator
  validates :visibility, presence: true

  def primary_terms
    [
      :rights_statement,
      :rights_note,
      :member_of_collection_ids,
      :artist,
      :color,
      :date_range,
      :denomination,
      :department,
      :description,
      :edge,
      :era,
      :figure,
      :geographic_origin,
      :master,
      :metal,
      :note,
      :object_type,
      :obverse_attributes,
      :obverse_legend,
      :obverse_type,
      :orientation,
      :part,
      :place,
      :references,
      :reverse_attributes,
      :reverse_legend,
      :reverse_type,
      :ruler,
      :series,
      :shape,
      :subject,
      :symbol,
      :workshop
    ]
  end
end
