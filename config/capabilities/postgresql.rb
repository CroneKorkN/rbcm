def postgres db: nil
  needs :database, :apt, :ip
  run "postgres"
end
