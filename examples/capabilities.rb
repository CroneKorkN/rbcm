node "first.example.com" do
  apt install: 'vim'
end

node "second.example.com" do
  apt install: 'vim'
end

def apt install:
  run "apt-get install -y #{install}",
    check: "dpkg-query -l #{install}"
end

def apt!
  file "/log",
    content: apt?(:install).join(", ") # => ['vim']
end
