module Paperplane
  module APNS
    @@certificate = nil
    mattr_accessor :certificate

    @@passphrase = nil
    mattr_accessor :passphrase

    @@gateway = 'gateway.push.apple.com'
    mattr_accessor :gateway

    @@port = 2195
    mattr_accessor :port

    def self.push(notification)
      Paperplane::APNS::Notifier.new.push(notification)
    end

    def self.configure(&block)
      require 'paperplane/apns/connection'
      require 'paperplane/apns/notification'
      require 'paperplane/apns/notifier'

      yield self

      Paperplane::APNS::Connection.build_default_context
    end
  end
end