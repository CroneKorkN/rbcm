class RBCM::Addon
  def initialize type: type, name: name
    @type, @name = type, name
    @addon_dir =  "/tmp/rbcm-addons/"
    @project = if [:file, :dir].include? type
      Project.new name
    elsif type == :github
      Project.new load_from_github name
    end
  end

  attr_reader :project, :type, :name, :repo

  def load_from_github repo
    dir = "#{@addon_dir}#{repo}"
    repo = if Dir.exist? dir
      Git.open dir
    else
      Git.clone "https://github.com/#{repo}.git",
        repo,
        path: @addon_dir
    end
    repo.checkout "master"
    repo.pull
    return dir
  end
end
