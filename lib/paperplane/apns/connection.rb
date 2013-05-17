require 'socket'
require 'openssl'

module Paperplane
  class Connection
    cattr_accessor :default_context
    @@default_context = nil

    def self.build_default_context
      @@default_context = self.build_context(Paperplane::APNS.certificate, Paperplane::APNS.passphrase)
    end

    def self.build_context(certificate_path, passphrase)
      certificate = File.read(certificate_path)
      OpenSSL::SSL::SSLContext.new.tap do |c|
        c.cert = OpenSSL::X509::Certificate.new(certificate)
        c.key  = OpenSSL::PKey::RSA.new(certificate, passphrase)
      end
    end

    def initialize(opts = nil)
      if opts
        @context = self.class.build_context(opts[:certificate, opts[:passphrase]])
        @gateway = opts[:gateway]
        @port    = opts[:port]
      else
        @context = self.class.default_context
        @gateway = Paperplane::APNS.gateway
        @port    = Paperplane::APNS.port
      end

      @ssl = nil
    end

    def open
      @ssl = open_connection
    end

    def open?
      @ssl != nil
    end

    def close
      if ssl.connected?
        @ssl.close
        @socket.close
      end
      @ssl = nil
    end

    def write(bytes)
      @ssl.write(bytes)
    end

    def read(size, buf = nil)
      @ssl.read(size, buf)
    end

    protected

    def open_connection
      @socket = TCPSocket.new(@gateway, @port)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)

      OpenSSL::SSL::SSLSocket.new(@socket, @context).tap do |ssl|
        ssl.sync = true
        ssl.connect
      end
    end

  end
end