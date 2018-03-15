#!/usr/local/bin/ruby

require 'fileutils'
require './lib.rb'
require './capabilities.rb'
require './job.rb'
require './node.rb'
require './command.rb'

class RBCM
  def initialize
    @nodes = {}
    @patterns = {} # collects definitions from nodes with regex patterns to be apllied after all nodes are collected
    Dir["../config/nodes/**/*.rb"].each do |file|
      self.instance_eval File.read(file)
    end
    @patterns.each do |pattern, definition|
      @nodes.each do |name, node|
        node << definition if name.match /#{pattern}/
      end
    end
  end

  def nodes names=nil
    return @nodes unless names
    definition = Proc.new # Proc.new without paramaters catches a given block
    [names].flatten.each do |name|
      @patterns[name] = definition and next if name.class == Regexp
      @nodes[name] = Node.new name unless @nodes[name]
      @nodes[name] << definition
    end
  end

  def render
    @nodes.each do |name, node|
      node.render
    end
    self
  end

  def apply
    # scp, ssh
  end

  def clear_cache
    FileUtils.rm_rf Dir.glob("#{dir_path}/*") if dir_path.present?
  end
end

with Time.now do
  rbcm = RBCM.new
  p "render:"
  rbcm.render
  pp rbcm.nodes
  log "rbmc took #{Time.now - self}"
end
