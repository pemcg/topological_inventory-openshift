require "topological_inventory/openshift/logging"
require "topological_inventory/providers/common/operations/source"
require "topological_inventory/openshift/connection"

module TopologicalInventory
  module Openshift
    module Operations
      class Source < TopologicalInventory::Providers::Common::Operations::Source
        include Logging

        attr_accessor :metrics

        def initialize(params = {}, request_context = nil, metrics = nil)
          super(params, request_context)
          self.metrics = metrics
        end

        private

        def connection_check
          connection_manager = TopologicalInventory::Openshift::Connection.new
          connection_manager.connect("openshift", :host => endpoint.host, :port => endpoint.port, :token => authentication.password)

          [STATUS_AVAILABLE, nil]
        rescue => e
          logger.availability_check("Failed to connect to Source id:#{source_id} - #{e.message}", :error)
          [STATUS_UNAVAILABLE, e.message]
        end
      end
    end
  end
end
