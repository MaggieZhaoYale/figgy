# frozen_string_literal: true
class NumismaticFirmDecorator < Valkyrie::ResourceDecorator
  display :name,
          :city

  def manageable_files?
    false
  end

  def manageable_order?
    false
  end

  def manageable_structure?
    false
  end

  def title
    [name, city].compact.join(", ")
  end
end
