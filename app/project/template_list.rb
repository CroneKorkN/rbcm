class Project::TemplateList < Array
  def for file_action
    template_name = file_action.job.params[:template]
    binding.pry
    sleep 1
    if template_name.start_with? "/" # `/template.txt`
      find{|template| template_name == template.clean_path}
    else # `template.txt`
      find{ |template|
        template.path.start_with? File.dirname(file_action.project_file.path) and
        template_name == template.clean_filename
      }
    end
  end

  def under file_action

  end
end
