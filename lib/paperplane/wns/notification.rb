require 'builder'

module Paperplane
  module WNS
    class Notification
      attr_reader :channel_uri

      def initialize(channel_uri, opts)
        @channel_uri = channel_uri
        @type = opts.fetch(:type, :toast)
        @options = opts
      end

      def to_xml
        builder = Builder::XmlMarkup.new
        case @type
        when :toast
          build_toast_body(builder)
        when :badge
          build_badge_body(builder)
        else
          ''
        end
      end

      def wns_type_header
        case @type
        when :toast then 'wns/toast'
        when :badge then 'wns/badge'
        when :tile then 'wns/tile'
        else
          'wns/raw'
        end
      end

      private

      def build_toast_body(builder)
        template = @options.fetch(:template, 'ToastText01')

        builder.toast do |b|
          b.visual do
            b.binding(template: template) do
              b.text(@options[:text], id: 1)
            end
          end
        end
      end

      def build_badge_body(builder)
        builder.badge(value: @options[:value])
      end

    end
  end
end