# frozen_string_literal: true
class NumismaticIssueWayfinder < BaseWayfinder
  relationship_by_property :members, property: :member_ids
  relationship_by_property :coins, property: :member_ids, model: Coin

  def coin_count
    @coin_count ||= query_service.custom_queries.count_members(resource: resource, model: Coin)
  end
end