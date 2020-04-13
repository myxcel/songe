#!/usr/bin/env ruby
# encoding: utf-8

require 'base32'
require 'base64'
require "#{File.dirname(__FILE__)}/crc16"

# Encoding
class Enc

  def Enc::encode(str)
    Base64::strict_encode64(str)
  end

  def Enc::decode(str)
    begin
      Base64::strict_decode64(str)
    rescue => ex
      raise RuntimeError, "Invalid data string format"
    end
  end

  def Enc::encode_pkey(str)
    encode_key_p((15 << 3).chr + str)
  end

  def Enc::encode_kkey(str)
    encode_key_p((10 << 3).chr + str)
  end

  def Enc::decode_key(str)
    begin
      str = Base32::decode(str)
    rescue => ex
      raise RuntimeError, "Invalid key string format"
    end
    key = str[0...-2]
    raise RuntimeError, "Invalid key string checksum" \
      unless Digest::CRC16.digest(key) == str[-2, 2]
    key[1..-1]
  end

  private

  def Enc::encode_key_p(str)
    str = str + Digest::CRC16.digest(str)
    Base32::encode(str)
  end
end
