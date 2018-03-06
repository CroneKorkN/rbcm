module Recipe::APT
  def package install: name
    `apt install #{name}`
  end
end
