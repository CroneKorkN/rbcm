def apt install:
  run "apt-get install -y #{install}",
    check: "dpkg-query -l #{install}"
end

node "example.com" do
  apt install: 'vim'
end
