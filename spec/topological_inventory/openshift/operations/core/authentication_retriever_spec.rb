require "topological_inventory/openshift/operations/core/authentication_retriever"

module TopologicalInventory
  module Openshift
    module Operations
      module Core
        RSpec.describe AuthenticationRetriever do
          let(:subject) { described_class.new(123) }

          let(:headers) { {"Content-Type" => "application/json"} }
          let(:internal_authentications_url) do
            "http://localhost:3000/internal/v0.0/authentications/123?expose_encrypted_attribute[]=password"
          end
          let(:internal_authentication_response) { {"password" => "token"} }

          before do
            stub_request(:get, internal_authentications_url).with(:headers => headers).to_return(
              :headers => headers, :body => internal_authentication_response.to_json
            )
          end

          around do |e|
            url = ENV["TOPOLOGICAL_INVENTORY_URL"]
            ENV["TOPOLOGICAL_INVENTORY_URL"] = "http://localhost:3000"
            uri = URI.parse(ENV["TOPOLOGICAL_INVENTORY_URL"])
            TopologicalInventoryApiClient.configure do |config|
              config.scheme = uri.scheme || "http"
              config.host = "#{uri.host}:#{uri.port}"
            end

            e.run

            ENV["TOPOLOGICAL_INVENTORY_URL"] = url
          end

          describe "#process" do
            it "returns the relevant authentication" do
              authentication = subject.process
              expect(authentication.class).to eq(TopologicalInventoryApiClient::Authentication)
              expect(authentication.password).to eq("token")
            end
          end
        end
      end
    end
  end
end