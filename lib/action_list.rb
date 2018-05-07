module ActionList
  def resolve_dependencies
    @actions = []
    self.each do |action|
      resolve_action_dependencies action
    end
    @actions.uniq
  end

  def resolve_triggers
    @actions = []
    self.each do |action|
      resolve_action_triggers action
    end
    @actions.reverse.uniq.reverse
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
