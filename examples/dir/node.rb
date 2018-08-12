node "example.com" do
  dir "/var/test"
  dir templates: "filesystem",
   user: :test,
   group: :test
end
