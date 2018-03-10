nodes [
  "fu.mo.fu",
  /.+\.ckn\.li/,
] do
    hostname :auto

    ip v4: '10.0.0.1',
      v6: '::1'

    apt install: [
      'iotop',
      'apache2'
    ]

    file '/testfile', content: "blablub"
end
