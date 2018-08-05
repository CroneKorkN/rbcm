class Project::TemplateList < Array
  def for path:, capability:
    find{ |template|
      if path[0] == "/"
        capability.project_file.project
      else

      end
    }
  end

  def under path:, capability:

  end
end
