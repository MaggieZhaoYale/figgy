# frozen_string_literal: true

class OrangelightCoinBuilder
  attr_reader :decorator, :parent
  def initialize(decorator)
    @decorator = decorator
    @parent = decorator.decorated_parent
  end

  def build
    clean_document(document_hash)
  end

  private

    def clean_document(hash)
      hash.delete_if do |_k, v|
        v.nil? || v.try(:empty?)
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def document_hash
      {
        id: decorator.orangelight_id,
        title_display: "Coin: #{decorator.coin_number}",
        pub_created_display: decorator.pub_created_display,
        access_facet: ["Online", "In the Library"],
        call_number_display: [decorator.call_number],
        call_number_browse_s: [decorator.call_number],
        location_code_s: [coin_location_code],
        location: [coin_library_location],
        location_display: [coin_full_location],
        format: ["Coin"],
        advanced_location_s: [coin_location_code],
        counter_stamp_s: decorator.counter_stamp,
        analysis_s: decorator.analysis,
        notes_display: decorator.public_note,
        find_place_s: decorator.find_place,
        find_date_s: decorator.find_date,
        find_feature_s: decorator.find_feature,
        find_locus_s: decorator.find_locus,
        find_number_s: decorator.find_number,
        find_description_s: decorator.find_description,
        die_axis_s: decorator.die_axis,
        size_s: decorator.size,
        technique_s: decorator.technique,
        weight_s: decorator.weight,
        pub_date_start_sort: parent.first_range&.start&.first.to_i,
        pub_date_end_sort: parent.first_range&.end&.first.to_i,
        holdings_1display: holdings_hash,
        issue_object_type_s: parent.object_type,
        issue_denomination_s: parent.denomination,
        issue_denomination_sort: parent.denomination&.first,
        issue_number_s: parent.issue_number.to_s,
        issue_metal_s: parent.metal,
        issue_metal_sort: parent.metal&.first,
        issue_shape_s: parent.shape,
        issue_color_s: parent.color,
        issue_edge_s: parent.edge,
        issue_era_s: parent.era,
        issue_ruler_s: parent.ruler,
        issue_ruler_sort: parent.ruler&.first,
        issue_master_s: parent.master,
        issue_workshop_s: parent.workshop,
        issue_series_s: parent.series,
        issue_place_s: [parent.rendered_place],
        issue_place_sort: parent.rendered_place,
        issue_obverse_figure_s: parent.obverse_figure,
        issue_obverse_symbol_s: parent.obverse_symbol,
        issue_obverse_part_s: parent.obverse_part,
        issue_obverse_orientation_s: parent.obverse_orientation,
        issue_obverse_figure_description_s: parent.obverse_figure_description,
        issue_obverse_figure_relationship_s: parent.obverse_figure_relationship,
        issue_obverse_legend_s: parent.obverse_legend,
        issue_obverse_attributes_s: parent.obverse_attributes,
        issue_reverse_figure_s: parent.reverse_figure,
        issue_reverse_symbol_s: parent.reverse_symbol,
        issue_reverse_part_s: parent.reverse_part,
        issue_reverse_orientation_s: parent.reverse_orientation,
        issue_reverse_figure_description_s: parent.reverse_figure_description,
        issue_reverse_figure_relationship_s: parent.reverse_figure_relationship,
        issue_reverse_legend_s: parent.reverse_legend,
        issue_reverse_attributes_s: parent.reverse_attributes,
        issue_references_s: parent.numismatic_citations,
        issue_references_sort: parent.numismatic_citations&.first,
        issue_artists_s: parent.numismatic_artists,
        issue_artists_sort: parent.numismatic_artists&.first
      }
    end

    def holdings_hash
      {
        "numismatics" => {
          "location" => coin_full_location,
          "library" => coin_library_location,
          "location_code" => coin_location_code,
          "call_number" => decorator.call_number,
          "call_number_browse" => decorator.call_number
        }
      }.to_json.to_s
    end

    def coin_location_code
      "num"
    end

    def coin_library_location
      "Rare Books and Special Collections"
    end

    def coin_full_location
      "Rare Books and Special Collections - Numismatics Collection"
    end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
