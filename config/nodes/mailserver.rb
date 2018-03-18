nodes "mail.sublimity.de" do
    hostname :auto

    file "/wwwwwwwwwwwww", includes_line: "HALLOOOOOO"

    ip v4: '10.0.0.1',
      v6: '::1'

    apt install: [
      'iotop',
      'apache2'
    ]

end
