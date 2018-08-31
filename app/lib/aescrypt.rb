class String
  def encrypt password
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    cipher.key = OpenSSL::Digest::SHA256.new(password).digest
    iv = cipher.random_iv
    Base64.encode64(iv + cipher.update(self) + cipher.final).chomp
  end

  def decrypt password
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.decrypt
    cipher.key = OpenSSL::Digest::SHA256.new(password).digest
    cipher.iv = Base64.decode64(self)[0..15]
    cipher.update(Base64.decode64(self)[16..-1]) + cipher.final
  end
end
