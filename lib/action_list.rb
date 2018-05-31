class ActionList < Array
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
    ActionList.new @actions.uniq
  end

  def resolve_triggers
    @actions = []
    self.each do |action|
      resolve_action_triggers action
    end
    ActionList.new @actions.reverse.uniq.reverse
  end

  def file path
    ActionList.new select{|action| action.path == path}
  end

  def unneccessary
    ActionList.new (self - neccessary)
  end

  def neccessary
    ActionList.new select.neccessary?
  end

  def approvable
    ActionList.new select.approvable?
  end

  def approved
    ActionList.new select.approved?
  end

  def applyable
    ActionList.new select.applyable?
  end

  def applied
    ActionList.new select.applied?
  end

  def succeeded
    ActionList.new applied.select.succeeded?
  end

  def failed
    ActionList.new applied.select.failed?
  end

  private

  def resolve_action_dependencies this
    self.select{ |action|
      this.dependencies.include? action.capability
    }.each{ |action|
      resolve_action_dependencies action
    }
    @actions << this
  end

  def resolve_action_triggers this
    self.select{ |action|
      this.trigger.one?{|trigger| action.triggered_by.include? trigger}
    }.each{ |action|
      resolve_action_triggers action
    }
    @actions << this
  end
end
