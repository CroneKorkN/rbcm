class RBCM::TemplateList < Array
  def for action
    template_name = action.job.params[:template]
    if template_name.start_with? "/" # `/template.txt`
      find{|template| template.clean_path == template_name}
    else # `template.txt`
      find{ |template|
        template.path.start_with? File.dirname(action.job.parent.path) and
        template.clean_filename == template_name
      }
    end
  end

  def under path
    find_all{ |template|
      template.path.start_with? path
    }
  end
end
