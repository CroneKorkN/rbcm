class String
  def encrypt password
    aes = OpenSSL::Cipher.new("AES-256-CBC")
    aes.encrypt
    aes.key = OpenSSL::Digest::SHA256.new(password).digest
    aes.iv = iv = aes.random_iv
    aes.update(self.strip)
    return (
      Base64.encode64(iv) + Base64.encode64(aes.final.to_s)
    ).chomp
  end

  def decrypt password
    aes = OpenSSL::Cipher.new("AES-256-CBC")
    aes.decrypt
    aes.key = OpenSSL::Digest::SHA256.new(password).digest
    aes.iv = Base64.decode64(self[0..23])
    aes.update(Base64.decode64(self[24..-1]))
    aes.final
  end
end
