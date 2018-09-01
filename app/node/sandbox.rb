# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class RBCM::Node::Sandbox
  attr_reader :content, :jobs

  def initialize node
    @node = node
    @name = node.name
    @dependency_cache = []
    @cache = {
      chain: [@node], trigger: [], triggered_by: [], check: [],
      source: [], tags: [], working_dirs: []
    }
    # define in instance, otherwise method-binding will be wrong (to class)
    @@capabilities = @node.rbcm.project.capabilities.each.name
    @node.rbcm.project.capabilities.each do |capability|
      __add_capability capability
    end
    # wrap base_capabilities
    [:file, :run].each do |base_capability|
      __add_capability RBCM::Project::Capability.new(
        name: base_capability,
        content: method(base_capability).unbind,
        project_file: false
      )
    end
  end

  def evaluate definitions
    [definitions].flatten.each do |definition|
      __cache chain: definition do
        instance_eval &definition.content
      end
    end
  end

  def tag name, &block
    __cache tags: name, chain: "tag:#{name}" do
      instance_eval &block
    end
  end

  def trigger name, &block
    __cache trigger: name, chain: "trigger:#{name}" do
      instance_eval &block
    end
  end

  def triggered_by name, &block
    __cache triggered_by: name, chain: "triggered_by:#{name}" do
      instance_eval &block
    end
  end

  def group name, &block
    if block_given? # expand group
      @node.rbcm.group_additions[name] << block
    else # include group
      raise "undefined group #{name}" unless @node.rbcm.groups[name]
      @node.memberships << name
      __cache chain: "group:#{name}" do
        @node.rbcm.groups[name].each do |definition|
          instance_eval &definition.content
        end
      end
    end
  end

  def user_password
    @node.rbcm.user_password ||= (print "enter project password: "; STDIN.gets)
  end

  def dont *params
    puts "dont #{params}"
  end

  def needs *capabilities
    @dependency_cache += [capabilities].flatten(1)
  end

  def check line, &block
    __cache check: line do
      instance_eval &block
    end
  end

  def localhost
    # mark node as local
  end

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

  def file path, tags: nil, trigger: nil, triggered_by: nil, **named
    raise "RBCM: invalid file paramteres '#{named}'" if (
      named.keys - [:exists, :after, :mode, :content, :includes,
        :template, :context, :tags, :user, :group]
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
    end if named.keys.include? :content or named.keys.include? :template
    run "chmod #{named[:mode]} '#{path}'",
      check: "stat -c '%a' * #{path} | grep -q #{named[:mode]}" if named[:mode]
    run "chown #{named[:user]} '#{path}'",
      check: "stat -c '%U' * #{path} | grep -q #{named[:user]}" if named[:user]
    run "chown :#{named[:group]} '#{path}'",
      check: "stat -c '%G' * #{path} | grep -q #{named[:group]}" if named[:group]
    end

  def dir path="/", templates:, context: {}, tags: nil, trigger: nil, triggered_by: nil
    templates.gsub! /\/^/, ''
    __cache tags: tags, trigger: trigger, triggered_by: triggered_by, working_dirs: working_dir do
      @node.rbcm.project.templates.under("#{working_dir}/#{templates}").each do |template|
        file path + template.clean_full_path.gsub(/^#{working_dir}\/#{templates}/, '').gsub(/^\/#{templates}/, ''),
          template: template.clean_path,
          context: context
      end
    end
  end

  def working_dir
    @cache[:chain].select{ |i|
      i.class == RBCM::Project::Definition or (
        i.class == RBCM::Project::Capability and not [:file, :run].include? i.name
      )
    }.last.project_file.path.split("/")[0..-2].join("/")
  end

  def decrypt secret
    AESCrypt.decrypt secret, File.read(File.expand_path("~/.rbcm.secret")).chomp
  end

  # handle getter method calls
  def method_missing name, *named, **ordered, &block
    #log "method #{name} missing on #{@name}"
    capability_name = name[0..-2].to_sym
    params = RBCM::Params.new named, ordered
    if not @@capabilities.include? capability_name
      super
    elsif name =~ /\!$/
      return # never call cap! diectly
    elsif name =~ /\?$/
      __search capability_name, params, &block
    end
  end

  def __search capability_name, params, &block
    if params[:nodes] == :all # scope
      jobs = @node.rbcm.jobs
    else
      jobs = @node.jobs
    end
    jobs = jobs.select{|job| job.capability.name == capability_name}
    if params.delete(:nodes).empty?
      # return ordered prarams
      r = jobs.collect{|job| job.params}
    elsif params[0].class == Symbol
      # return values of a named param
      r = jobs.find_all{ |job|
        job.params.named.include? params.first if job.params.named.any?
      }.collect{ |job|
        job.params.named
      }.collect{ |named_params|
        named_params[params.first]
      }
    elsif params.named.any?
      if params[:with]
        # return values of a named param
        r = jobs.find_all{ |job|
          job.params.named.keys.include? params[:with] and job.params.named.any?
        }.collect{ |job|
          params = job.params
          params[:source] = job.node.name
          params
        }
      end
    end
    return r.collect &block if block_given? # no-each-syntax
    #return r
    r.extend RBCM::JobSearch
    r
  end

  def __cache trigger: nil, triggered_by: nil, params: nil, check: nil,
      chain: nil, source: nil, reset: nil, tags: nil, working_dirs: nil
    @cache[:source].append []             if chain
    @cache[:source].last  << source       if source
    @cache[:chain]        << chain        if chain
    @cache[:tags]         << tags         if tags
    @cache[:trigger]      << trigger      if trigger
    @cache[:triggered_by] << triggered_by if triggered_by
    @cache[:check]        << check        if check
    @cache[:working_dirs] << working_dirs if working_dirs
    r = yield if block_given?
    @cache[:source].pop                   if chain
    @cache[:chain].pop                    if chain
    @cache[:tags].pop                     if tags
    @cache[:trigger].pop                  if trigger
    @cache[:triggered_by].pop             if triggered_by
    @cache[:check].pop                    if check
    @cache[:working_dirs].pop             if working_dirs
    @cache[reset]         =  []           if reset
    r
  end

  def __add_capability capability
    @@capabilities << capability.name unless capability.name[-1] == "!"
    # define capability method
    define_singleton_method :"__#{capability.name}", &capability.content.bind(self)
    # define wrapper method
    if capability.type == :regular
      define_singleton_method capability.name do |*ordered, **named|
        params = RBCM::Params.new ordered, named
        @node.jobs.append RBCM::Node::Job.new(
          node: @node,
          capability: capability,
          params: params
        )
        @node.triggered.append capability.name
        r = __cache trigger: params[:trigger],
              triggered_by: params[:triggered_by],
              chain: capability do
          send "__#{__method__}", *params.delete(:trigger, :triggered_by).sendable
        end
        @dependency_cache = [:file]
        r
      end
    elsif capability.type == :final
      define_singleton_method capability.name do
        r = __cache chain: capability do
          send "__#{__method__}"
        end
        @dependency_cache = [:file]
        r
      end
    else
      raise "unknown capability type #{capability.type}"
    end
    # return RBCM::JobSearch.new r
  end

  def self.capabilities
    @@capabilities.uniq
  end
end
