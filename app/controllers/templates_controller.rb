# frozen_string_literal: true
class TemplatesController < ApplicationController
  include Valhalla::ResourceController
  self.change_set_class = TemplateChangeSet
  self.resource_class = Template
  self.change_set_persister = ::PlumChangeSetPersister.new(
    metadata_adapter: Valkyrie::MetadataAdapter.find(:indexing_persister),
    storage_adapter: Valkyrie.config.storage_adapter
  )

  before_action :find_parent, only: [:new, :create, :destroy]

  def find_parent
    @parent ||= query_service.find_by(id: Valkyrie::ID.new(params[:ephemera_project_id]))
  end

  def new
    @parent_change_set = TemplateChangeSet.new(Template.new(model_class: params[:model_class]))
    @parent_change_set.prepopulate!
    @change_set = @parent_change_set.child_change_set
  end

  def after_create_success(_obj, _change_set)
    redirect_to solr_document_path(id: "id-#{@parent.id}")
  end

  def after_delete_success
    after_create_success(nil, nil)
  end

  def resource_params
    params[:template].merge(parent_id: @parent.id.to_s)
  end

  def _prefixes
    @_prefixes ||= super + ['valhalla/base']
  end
end