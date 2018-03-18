#!/usr/local/bin/ruby

require "fileutils"
require "./lib.rb"
require "./capabilities.rb"
require "./command.rb"
require "./node_file.rb"
require "./definition.rb"
require "./job.rb"
require "./node.rb"

class RBCM
  attr_accessor :nodes

  def initialize
    @nodes = {}
    load!
    #run!
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
          patterns[node_name] << node_file.jobs
        end
      end
    end
    # apply patterns after all explicit definitions are loaded
    patterns.each do |pattern, definition|
      @nodes.each do |name, node|
        node << definition if name.match /#{pattern}/
      end
    end
  end

  def run!
    @nodes.each {|node| node.run!}
  end

  def diff!

  end

  def apply!

  end
end

pp RBCM.new
