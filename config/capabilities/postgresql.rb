def postgres
  needs :database
  run "postgres"
end
