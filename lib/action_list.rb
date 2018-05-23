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

  def approvable
    actions = []
    self.each do |action|
      actions << action unless action.obsolete or action.approved != nil or action.not_triggered
    end
    ActionList.new actions
  end

  def unapprovable
    ActionList.new (self - approvable)
  end

  def approved
    actions = []
    self.each do |action|
      actions << action if action.approved
    end
    ActionList.new actions
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
