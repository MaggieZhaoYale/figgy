# frozen_string_literal: true
class ChangeSet < Valkyrie::ChangeSet
  class_attribute :workflow_class
  def self.apply_workflow(workflow)
    self.workflow_class = workflow
    include(ChangeSetWorkflow)
  end

  def prepopulate!
    super.tap do
      @_changes = Disposable::Twin::Changed::Changes.new
    end
  end
end
