module Recipe::File
  def file path,
      exists: false,
      includes_line: nil

    apt install: 'something'

    if exists
      "touch path"
    end
  end
end
