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
