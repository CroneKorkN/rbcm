def database
  if options :postgres
    needs postgres
  elsif options :mysql
    needs mysql
  end
end
