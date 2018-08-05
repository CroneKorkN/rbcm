class Project::TemplateList < Array
  def for file_action
    target_filename = file_action.job.params[0]
    if target_filename.start_with? "/"
      find do |template|
        project_path = file_action.capability.project_file.project.path
        template.path == "#{project_path}#{target_filename}"
      end
    else
      find_all do |template|
        # template.path.start_with? file_action.capability.project_file.project.path and
        # template.target_filename == file_action.job.params[0]
      end
    end
  end

  def under file_action

  end
end
