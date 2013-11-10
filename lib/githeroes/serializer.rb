require 'githeroes'

module Githeroes::Serializer
  extend self

  def load(data)
    Marshal.load(Zlib::Inflate.inflate(data))
  end

  def dump(data)
    Zlib::Deflate.deflate(Marshal.dump(data))
  end
end