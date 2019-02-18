def needs *_, **_
  # apt 
  yield
end

def needed_by *_, **_
  yield
end
