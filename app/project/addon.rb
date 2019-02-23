class RBCM::Addon < RBCM::Project
  def initialize type:, name:, rbcm:
    @type, @name, @rbcm = type, name, rbcm
    if [:file, :dir].include? type
      super name
    elsif type == :github
      super load_from_github(name), rbcm: rbcm
    end
  end

  attr_reader :project, :type, :name, :repo

  def load_from_github repo
    addon_dir =  "/tmp/rbcm-addons/"
    dir = "#{addon_dir}#{repo}"
    repo = if Dir.exist? dir
      Git.open dir
    else
      Git.clone "https://github.com/#{repo}.git",
        repo,
        path: addon_dir
    end
    repo.checkout "master"
    repo.pull
    return dir
  end
end
