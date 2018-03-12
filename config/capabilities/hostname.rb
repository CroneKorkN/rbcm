def hostname name, bla=1, test: nil, test2: 123, test3: 87584
  file '/etc/hostname', content: "bliblablubb"
end
