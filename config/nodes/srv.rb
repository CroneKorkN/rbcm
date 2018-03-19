nodes "srv.ckn.li" do
  ip "aaa"
  ip ["bbb", "ccc"]
  apt install: [
    :apache2, :postgresql, :'redis-server'
  ]

  service :apache2, :restart

  apt install: :blablub
  apt "JODEL"

  file "/MÖÖÖÖÖÖÖPULUS", content: "
    WISSE
    MER
    NET
  "
  file "/matchorator", mode: 777
  file "/matchorator", mode: 777
  file "/matchorator", mode: 777
  file "/matchorator", mode: 777
  file "/matchorator", mode: 777

  ubuntu :trusty

  p ubuntu?

  if apt?(:install).include? :blablub
    p "HALLO"
  end
  if apt?(:install).include? :blablddub
    p "HALLO222"
  end

  postgres db: "hallodb"
end
