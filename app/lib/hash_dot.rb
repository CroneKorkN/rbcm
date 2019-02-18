class HashDot < Hash
  def method_missing name, value=nil
    if key? name.to_s
      if value
        store name.to_s, value
      else
        fetch name.to_s
      end
    elsif key? name.to_sym
      if value
        store name.to_sym, value
      else
        fetch name.to_sym
      end
    else
      if value
        store name.to_s.gsub(/=$/, '').to_sym, value
      else
        nil
      end
    end
  end
end
