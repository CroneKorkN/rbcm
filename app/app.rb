#!/usr/local/bin/ruby

require "fileutils"
require "./lib.rb"
require "./node_file.rb"
require "./node.rb"
require "./capabilities.rb"
require "./command_list.rb"
require "./command.rb"
require "./definition.rb"
require "./job.rb"

class RBCM
  attr_reader :nodes

  def initialize
    @nodes = {}
    load!
    run!
    #diff!
    #apply!
  end

  def load!
    patterns = {}
    Dir["../config/nodes/**/*.rb"].each do |path|
      node_file = NodeFile.new(path)
      node_file.affected_nodes.each do |node_name|
        unless node_name.class == Regexp
          @nodes[node_name] = Node.new unless @nodes[node_name]
          @nodes[node_name] << node_file.jobs
        else
          patterns[node_name] = [] unless patterns[node_name]
          patterns[node_name] += node_file.jobs
        end
      end
    end
    # apply patterns after all explicit definitions are loaded
    patterns.each do |pattern, jobs|
      @nodes.each do |name, node|
        node << jobs if name.match /#{pattern}/
      end
    end
  end

  def run!
    @nodes.each {|name, node| node.commands}
  end

  def diff!

  end

  def apply!

  end
end

rbcm = RBCM.new
#puts rbcm.nodes.first[1].commands.collect{|command| command.line}.join("\n")
rbcm.nodes.each do |name, node|
 puts name
 puts node.commands
end
#pp rbcm
