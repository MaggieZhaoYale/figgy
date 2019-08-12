# frozen_string_literal: true
class FindDeepFailedCloudFixityCount
  def self.queries
    [:find_deep_failed_cloud_fixity_count]
  end

  attr_reader :query_service
  delegate :resource_factory, to: :query_service
  def initialize(query_service:)
    @query_service = query_service
  end

  def find_deep_failed_cloud_fixity_count(resource:)
    query_service.connection[relationship_query, id: resource.id.to_s].first[:count]
  end

  def relationship_query
    <<-SQL
        WITH RECURSIVE deep_members AS (
          select member.*
          FROM orm_resources a,
          jsonb_array_elements(a.metadata->'member_ids') AS b(member)
          JOIN orm_resources member ON (b.member->>'id')::UUID = member.id
          WHERE a.id = :id
          UNION
          SELECT mem.*
          FROM deep_members f,
          jsonb_array_elements(f.metadata->'member_ids') AS g(member)
          JOIN orm_resources mem ON (g.member->>'id')::UUID = mem.id
          WHERE f.metadata @> '{"member_ids": [{}]}'
        ), deep_events AS (
          select member.id AS file_set_id, event.metadata->'resource_id'->0->>'id' AS id, event.metadata->'child_id'->0->>'id' AS child_id, event.metadata->'status'->>0 AS status, event.metadata->'child_property'->>0 AS child_property, event.updated_at
          from deep_members member
          JOIN orm_resources po ON member.id = (po.metadata->'preserved_object_id'->0->>'id')::UUID
          JOIN orm_resources event ON po.id = (event.metadata->'resource_id'->0->>'id')::UUID
          WHERE member.internal_resource = 'FileSet'
          AND po.internal_resource = 'PreservationObject'
          AND event.internal_resource = 'Event'
        )
        select COUNT(DISTINCT deep_events.file_set_id) FROM (
          select file_set_id, id, child_id, child_property, MAX(event.updated_at) AS updated_at FROM deep_events event
          GROUP BY file_set_id, id, child_id, child_property
        ) AS latest_events
        INNER JOIN deep_events
        ON deep_events.id = latest_events.id
        AND deep_events.updated_at = latest_events.updated_at
        AND deep_events.child_id = latest_events.child_id
        AND deep_events.child_property = latest_events.child_property
        AND deep_events.status = 'FAILURE'
    SQL
  end
end
