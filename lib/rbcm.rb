puts "\n================ RBCM starting ================\n\n"

require "net/ssh"
require "net/scp"
require "fileutils"
require "shellwords"
require "diffy"

APPDIR = File.expand_path File.dirname(__FILE__)
[ :lib, :action, :definition_file, :file_system, :file_action, :node,
  :action_list, :command, :job, :remote, :sandbox, :array_hash, :params,
  :template, :core
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class CLI
  def initialize rbcm
    rbcm.parse
    rbcm.approve
    rbcm.apply
  end

  def check command

  end

  def approve command

  end
end
