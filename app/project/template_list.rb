class Project::TemplateList < Array
  def for file_action
    template_name = file_action.job.params[:template]
    if template_name.start_with? "/" # `/template.txt`
      find{|template| template.clean_path == template_name}
    else # `template.txt`
      find{ |template|
        template.path.start_with? File.dirname(file_action.project_file.path) and
        template.clean_filename == template_name
      }
    end
  end

  def under file_action
    find_all{ |template|
      template.path.start_with? File.dirname(file_action.project_file.path)
    }
  end
end
