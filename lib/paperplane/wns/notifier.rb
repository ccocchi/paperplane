require 'net/http'
require 'uri'
require 'thread'

module Paperplane
  module WNS
    class Notifier
      ACCESS_TOKEN_URI = URI.parse('https://login.live.com/accesstoken.srf')
      ACCESS_TOKEN_SCOPE = 'notify.windows.com'
      ACCESS_TOKEN_GRANT_TYPE = 'client_credentials'

      @@lock = Mutex.new

      @@access_token = nil
      @@token_refreshed_at = nil

      class << self
        def refresh_access_token
          @@lock.synchronize do
            unless @@token_refreshed_at && @@token_refreshed_at >= 1.hour.ago
              @@access_token = get_access_token
              @@token_refreshed_at = Time.now
            end
          end
          @@access_token
        end

        def build_https_request(uri)
          http = http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          # http.verify_mode = OpenSSL::SSL::VERIFY_PEER

          return http, Net::HTTP::Post.new(uri.request_uri)
        end

        private

        def get_access_token
          http, request = self.build_https_request(ACCESS_TOKEN_URI)

          request.set_form_data({
            grant_type: ACCESS_TOKEN_GRANT_TYPE,
            client_id: Paperplane::WNS.client_id,
            client_secret: Paperplane::WNS.client_secret,
            scope: ACCESS_TOKEN_SCOPE
          })

          response = http.request(request)
          if response.code == '200'
            Oj.load(response.body)['access_token']
          else
            nil
          end
        end
      end

      CONTENT_TYPE_XML = 'text/xml'

      def initialize(access_token = nil)
        self.class.refresh_access_token unless @@access_token
        @access_token = access_token || @@access_token
      end

      def push(notification)
        uri = URI.parse(notification.channel_uri)
        http, request = self.class.build_https_request(uri)

        request['Authorization'] = "Bearer #{@access_token}"
        request['Content-Type']  = CONTENT_TYPE_XML
        request['X-WNS-Type']    = notification.wns_type_header

        request.body = notification.to_xml

        response = http.request(request)
        if response.code == '401'
          @access_token = self.class.refresh_access_token
          request['Authorization'] = "Bearer #{@access_token}"
          response = http.request(request)
        end
        response.code == '200'
      end
    end
  end
end