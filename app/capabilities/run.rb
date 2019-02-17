def run action, check: nil, tags: nil, trigger: nil, triggered_by: nil
  __cache check: check, tags: tags, trigger: trigger, triggered_by: triggered_by, working_dirs: working_dir do
    @node.actions << RBCM::Action::Command.new(
      job: @node.jobs.last,
      line: action,
      dependencies: @dependency_cache.dup,
      state: @cache.collect{|k,v| [k, v.dup]}.to_h,
    )
  end
end
