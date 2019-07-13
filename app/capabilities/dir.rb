def dir path="/", templates: nil, context: {}
  run "mkdir -p #{path}"
  # templates.gsub! /\/^/, ''
  # @job.rbcm.templates.under("#{working_dir}/#{templates}").each do |template|
  #   file path + template.clean_full_path.gsub(/^#{working_dir}\/#{templates}/, '').gsub(/^\/#{templates}/, ''),
  #     template: template.clean_path,
  #     context: context
  # end
end


#def dir *_
#end
