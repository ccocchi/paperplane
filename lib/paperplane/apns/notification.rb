module Paperplane
  class Notification
    PACK = 'CNNnH64nA*'

    attr_reader :alert, :badge, :sound, :other

    def initialize(device_token, message)
      @devise_token = device_token

      case message
      when Hash
        @alert = message.fetch(:alert)
        @badge = message[:badge]
        @sound = message[:sound]
        @other = message[:other]
      when Message
        @alert = message
      end
    end

    def to_bytes
      pm = packaged_message

      [
        1,
        0,  # identifier
        0,  # expiry
        32, # token length
        @device_token,
        pm.bytesize,
        pm
      ].pack(PACK)
    end

    private

    def packaged_message
      aps_hash = { 'alert' => alert }
      aps_hash['badge'] = badge if badge
      aps_hash['sound'] = sound if sound
      result = { 'aps' => aps_hash }
      result.merge!(other) if other && other.is_a?(Hash)
      Oj.dump(result)
    end

  end
end