class Sandbox
  def stage name
    if stage == :import
      Sandbox.include Sandbox::Import
      Sandbox.extend Sandbox::Import::ClassMethods
    elsif stage == :parse
      Sandbox.exclude Sandbox::Import
    end
  end
end
