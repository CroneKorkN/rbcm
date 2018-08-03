node "example.com" do
  dir "/var/test", user: :test, group: :test, executable: true
  dir templates: "filesystem"  # equals `dir "/", templates: "filesystem"``
end
