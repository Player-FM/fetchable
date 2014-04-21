module Fetchery

  class Util

    BASE_CHARS = Array('A'..'Z') + Array('a'..'z') - 'ioIO'.split(//)

    def self.decode(str)
      i = 0
      decoded = 0
      str.split(//).reverse.each do |a|
        decoded += BASE_CHARS.index(a) * (BASE_CHARS.size ** i)
        i += 1
      end
      decoded
    end

    def self.encode(num)
      encoded = ''
      while num > 0
        encoded = BASE_CHARS[num % BASE_CHARS.size].to_s + encoded
        num /= BASE_CHARS.size
      end
      encoded
    end

  end

end
