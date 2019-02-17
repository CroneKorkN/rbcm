class RBCM::ActionList < Array
  def initialize array=[]
    array.each do |element|
      insert -1, element
    end
  end

  def resolve_dependencies
    @actions = []
    self.each do |action|
      resolve_action_dependencies action
    end
    RBCM::ActionList.new @actions
  end

  def resolve_triggers
    @actions = []
    self.each do |action|
      resolve_action_triggers action
    end
    RBCM::ActionList.new @actions
  end

  def tags tags
    RBCM::ActionList.new select{|action| 
      tags.one?{|tag| action.tags.include?(tag)}
  }
  end

  def file path
    RBCM::ActionList.new select{|action| action.path == path}
  end

  def node node_name
    return self unless node_name
    RBCM::ActionList.new select{|action| action.job.node.name == node_name}
  end

  def checkable
    RBCM::ActionList.new select.checkable?
  end

  def unneccessary
    RBCM::ActionList.new (self - neccessary)
  end

  def neccessary
    RBCM::ActionList.new select.neccessary?
  end

  def approvable
    RBCM::ActionList.new select.approvable?
  end

  def approved
    RBCM::ActionList.new select.approved?
  end

  def applyable
    RBCM::ActionList.new select.applyable?
  end

  def applied
    RBCM::ActionList.new select.applied?
  end

  def succeeded
    RBCM::ActionList.new applied.select.succeeded?
  end

  def failed
    RBCM::ActionList.new applied.select.failed?
  end

  private

  def resolve_action_dependencies this
    self.select{ |action|
      this.dependencies.include? action.job.capability
    }.each{ |action|
      resolve_action_dependencies action
    }
    @actions << this unless @actions.include? this
  end

  def resolve_action_triggers this
    self.select{ |action|
      this.trigger.one?{|trigger| action.triggered_by.include? trigger}
    }.each{ |action|
      resolve_action_triggers action
    }
    @actions << this unless @actions.include? this
  end
end
