def ubuntu version=nil
  run "ubuntu #{version}"

  file "/home/root/testfile.sh", mode: 777, content: "LALEU"
end
