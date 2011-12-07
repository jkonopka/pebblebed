# Extends Sinatra for maximum pebble pleasure
require 'pebblebed'

module Sinatra
  module Pebblebed
    module Helpers      
      # Render the markup for a part. A partspec takes the form
      # "<kit>.<partname>", e.g. "base.post"
      def part(partspec, params)
        ::Pebblebed.parts.markup(partspec, params)
      end

      def checkpoint_session
        params[:session] || request.cookies['checkpoint.session']
      end

      def pebbles
        @pebbles ||= ::Pebblebed::Connector.new(checkpoint_session, :host => request.host)
      end

      def current_identity
        pebbles.checkpoint.me
      end

      def require_identity
        unless current_identity.respond_to?(:id)
          halt 403, "No current identity."
        end
      end

      def require_god
        unless current_identity.try(:god)
          halt 403, "Current identity is not a god."
        end
      end
    end

    def self.registered(app)
      app.helpers(Sinatra::Pebblebed::Helpers)
      app.get "/ping" do
        "{\"name\":#{(app.service_name || 'undefined').to_s.inspect}}"
      end
    end

    def declare_pebbles(&block)
      ::Pebblebed.config(&block)
    end

    def i_am(service_name)
      set :service_name, service_name
    end

  end
end