class Project::TemplateList < Array
  def for file_action
    template_name = file_action.job.params[:template]
    if template_name.start_with? "/" # `/template.txt`
      find{|template| template.clean_path == template_name}
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
