nodes [
  "test.ckn.li",
  /.+.foo.ckn.li/,
] do
    hostname :auto

    ip v4: '10.0.0.1',
      v6: '::1'

    package install: [
      'iotop',
      'apache2'
    ]
end
