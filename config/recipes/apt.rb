module Recipe::APT
  def package install: name
    run 'apt install #{name}'
  end
end
