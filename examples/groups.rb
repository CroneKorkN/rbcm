node "first.example.com" do
  group :debian_servers
end

node "second.example.com" do
  group :debian_servers
end

group :debian_servers do
  run "ls /"
end
