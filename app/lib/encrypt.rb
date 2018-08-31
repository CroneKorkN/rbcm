class String
  def encrypt password
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    cipher.key = OpenSSL::Digest::SHA256.new(password).digest
    iv = cipher.random_iv
    marked = '.'*12 + self
    Base64.encode64(iv + cipher.update(marked) + cipher.final).chomp
  end

  def decrypt password
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.decrypt
    cipher.key = OpenSSL::Digest::SHA256.new(password).digest
    cipher.iv = Base64.decode64(self)[0..15]
    marked = cipher.update(Base64.decode64(self)[16..-1]) + cipher.final
    p marked[0..11]
    raise "ERROR: wrong password" if marked[0..11] != '.'*12
    marked[12..-1]
  end
end
