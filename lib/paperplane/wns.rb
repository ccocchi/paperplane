module Paperplane
  module WNS
    @@client_id = nil
    mattr_accessor :client_id

    @@client_secret = nil
    mattr_accessor :client_secret

    def self.push(notification)
      Paperplane::WNS::Notifier.new.push(notification)
    end

    def self.configure(&block)
      require 'paperplane/wns/notification'
      require 'paperplane/wns/notifier'

      yield self
    end
  end
end

