class RBCM::TemplateList < Array
  def for file_action
    if file_action.job.params[0] == "/"
      find do |template|
        template.path.start_with? file_action.capability.project_file.project.path and
        template.target_filename == file_action.job.params[0]
      end
    else
    end
  end

  def under file_action

  end
end
