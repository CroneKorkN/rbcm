class Params < Array
  def ordered_params
    named_params? ? self[0..-2] : @params
  end

  def named_params
    @params.last if named_params?
  end

  def named_params?
    @params.last.class == Hash
  end
end