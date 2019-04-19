# frozen_string_literal: true
class NumismaticAccessionDecorator < Valkyrie::ResourceDecorator
  display :accession_number,
          :date,
          :items_number,
          :type,
          :cost,
          :account,
          :person,
          :firm,
          :note,
          :private_note,
          :citations

  delegate :decorated_person, to: :wayfinder

  def date
    Array.wrap(super).first
  end

  def person
    return nil unless decorated_person
    [decorated_person.name1, decorated_person.name2].compact.join(" ")
  end

  def firm
    Array.wrap(super).first
  end

  def type
    Array.wrap(super).first
  end

  def cost
    Array.wrap(super).first
  end

  def account
    Array.wrap(super).first
  end

  def citations
    numismatic_citation.map { |c| c.decorate.title }
  end

  def manageable_files?
    false
  end

  def manageable_structure?
    false
  end

  def label
    "#{accession_number}: #{date} #{type} #{from_label} #{cost_label}"
  end

  def from_label
    divider = "/" if person && firm
    "#{person}#{divider}#{firm}"
  end

  def cost_label
    "" unless cost
    "(#{cost})"
  end
end
