def file path, tags: nil, trigger: nil, triggered_by: nil, **named
  raise "RBCM: invalid file parameters '#{named}'" if (
    named.keys - [:exists, :after, :mode, :content, :includes,
      :template, :provide, :provide_once, :context, :tags, :user, :group]
  ).any?
  job = @node.jobs.last
  run "mkdir -p #{File.dirname path}",
    check: "ls #{File.dirname path}"
  __cache tags: tags, trigger: trigger, triggered_by: triggered_by, working_dirs: working_dir do
    @node.actions << RBCM::Action::File.new(
      job: job,
      params: RBCM::Params.new([path], named),
      state: @cache.collect{|k,v| [k, v.dup]}.to_h
    )
  end if (named.keys - [
    :content, :includes, :template, :provide, :provide_once
  ]).length < named.keys.length
  run "chmod #{named[:mode]} '#{path}'",
    check: "stat -c '%a' * #{path} | grep -q #{named[:mode]}" if named[:mode]
  run "chown #{named[:user]} '#{path}'",
    check: "stat -c '%U' * #{path} | grep -q #{named[:user]}" if named[:user]
  run "chown :#{named[:group]} '#{path}'",
    check: "stat -c '%G' * #{path} | grep -q #{named[:group]}" if named[:group]
end
