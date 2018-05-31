node "example.com" do
  run "apt-get install -y vim",
    check: "dpkg-query -l vim"
end
