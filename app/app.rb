#!/usr/local/bin/ruby

require "fileutils"
require "./lib.rb"
require "./capabilities.rb"
require "./command.rb"
require "./definition_file.rb"
require "./job.rb"
require "./node.rb"

class RBCM
  attr_accessor :nodes

  def initialize
    @nodes = {}
  end

  def load_definitions!
    patterns = {}
    Dir["../config/nodes/**/*.rb"].each do |path|
      definition_file = DefinitionFile.new(path)
      definition_file.affected_nodes.each do |node_name|
        unless node_name.class == Regexp
          @nodes[node_name] = Node.new unless @nodes[node_name]
          @nodes[node_name] << definition_file.definition
        else
          patterns[node_name] = [] unless patterns[node_name]
          patterns[node_name] << definition_file.definition
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

  def parse_definitions!

  end
end

rbcm = RBCM.new
rbcm.load_definitions!
rbcm.parse_definitions!

pp rbcm
