# frozen_string_literal: true
class BulkIngestController < ApplicationController
  def show
    authorize! :create, resource_class
    @states = workflow_states
    @resource_class = resource_class
  end

  def browse_everything_files
    if file_paths.max_parent_path_depth == 1
      IngestFolderJob.perform_later(directory: parent_path.to_s, file_filter: nil, class_name: resource_class_name, **attributes)
    else
      IngestFoldersJob.perform_later(directory: parent_path.to_s, file_filter: nil, class_name: resource_class_name, **attributes)
    end

    redirect_to root_url, notice: "Batch Ingest of #{resource_class.human_readable_type.pluralize} started"
  end

  private

    def attributes
      {
        state: params[:workflow][:state],
        visibility: params[:visibility]
      }
    end

    def file_paths
      @file_paths ||= BrowseEverythingFilePaths.new(selected_files_param)
    end

    def multi_volume_work?
      params[:mvw] == "true"
    end

    def parent_path
      path = file_paths.parent_path
      if multi_volume_work? && file_paths.max_parent_path_depth == 2
        # Single multi-volume works need a parent path one level above to ingest properly.
        # Otherwise, they are indistinguishable from multiple singe-volume works.
        File.dirname(path)
      else
        path
      end
    end

    def resource_class
      resource_class_name.constantize
    end

    def resource_class_name
      params[:resource_type].classify
    end

    def selected_files_param
      params[:selected_files].to_unsafe_h
    end

    def workflow
      WorkflowRegistry.workflow_for(resource_class)
    end

    def workflow_states
      workflow.aasm.states.map { |s| s.name.to_s }
    end
end