# frozen_string_literal: true
require "rails_helper"
require "ruby-progressbar/outputs/null"

RSpec.describe Reindexer do
  let(:solr_adapter) { Valkyrie::MetadataAdapter.find(:index_solr) }
  let(:postgres_adapter) { Valkyrie::MetadataAdapter.find(:postgres) }
  let(:logger) { instance_double("Logger").as_null_object }
  let(:progress_bar) { ProgressBar.create(output: ProgressBar::Outputs::Null) }

  before do
    allow(ProgressBar).to receive(:create).and_return(progress_bar)
    Valkyrie.logger.level = Logger::ERROR
  end

  describe ".reindex_all" do
    context "when there are records not in solr" do
      it "puts them in solr" do
        resource = FactoryBot.build(:scanned_resource)
        output = postgres_adapter.persister.save(resource: resource)
        expect { solr_adapter.query_service.find_by(id: output.id) }.to raise_error Valkyrie::Persistence::ObjectNotFoundError

        described_class.reindex_all(logger: logger, wipe: true)

        expect { solr_adapter.query_service.find_by(id: output.id) }.not_to raise_error
      end
    end
    it "reindexes multiple records" do
      5.times do
        postgres_adapter.persister.save(resource: FactoryBot.build(:scanned_resource))
      end

      described_class.reindex_all(logger: logger, wipe: true, batch_size: 2)
      expect(solr_adapter.query_service.find_all.to_a.length).to eq 5
    end

    context "when given ProcessedEvents" do
      it "doesn't index them" do
        resource = FactoryBot.build(:processed_event)
        output = postgres_adapter.persister.save(resource: resource)

        described_class.reindex_all(logger: logger, wipe: true)

        expect { solr_adapter.query_service.find_by(id: output.id) }.to raise_error Valkyrie::Persistence::ObjectNotFoundError
      end
    end

    context "when there are records in solr which are no longer in postgres" do
      it "gets rid of them" do
        resource = FactoryBot.build(:scanned_resource)
        output = solr_adapter.persister.save(resource: resource)

        described_class.reindex_all(logger: logger, wipe: true)

        expect { solr_adapter.query_service.find_by(id: output.id) }.to raise_error Valkyrie::Persistence::ObjectNotFoundError
      end
      it "doesn't get rid of them if you tell it not to wipe" do
        resource = FactoryBot.build(:scanned_resource)
        output = solr_adapter.persister.save(resource: resource)

        described_class.reindex_all(logger: logger, wipe: false)

        expect { solr_adapter.query_service.find_by(id: output.id) }.not_to raise_error
      end
    end

    context "when rsolr raises errors" do
      let!(:resources) do
        Array.new(5) do
          postgres_adapter.persister.save(resource: FactoryBot.build(:scanned_resource))
        end
      end

      before do
        allow_any_instance_of(Valkyrie::Persistence::Solr::Persister).to receive(:save_all).and_call_original
        allow_any_instance_of(Valkyrie::Persistence::Solr::Persister).to receive(:save).and_call_original
      end

      it "tolerates RSolr::Error::ConnectionRefused, logging bad id" do
        allow_any_instance_of(Valkyrie::Persistence::Solr::Persister).to receive(:save_all).with(resources: resources).and_raise RSolr::Error::ConnectionRefused
        allow_any_instance_of(Valkyrie::Persistence::Solr::Persister).to receive(:save).with(resource: resources[0]).and_raise RSolr::Error::ConnectionRefused

        described_class.reindex_all(logger: logger, wipe: true)

        expect(solr_adapter.query_service.find_all.to_a.length).to eq 4
        expect(logger).to have_received(:error).with("Could not index #{resources[0].id}")
      end

      it "tolerates RSolr::Error::Http, logging bad id" do
        allow_any_instance_of(Valkyrie::Persistence::Solr::Persister).to receive(:save_all).with(resources: resources).and_raise RSolr::Error::Http.new({ uri: "http://example.com" }, nil)
        allow_any_instance_of(Valkyrie::Persistence::Solr::Persister).to receive(:save).with(resource: resources[0]).and_raise RSolr::Error::Http.new({ uri: "http://example.com" }, nil)

        described_class.reindex_all(logger: logger, wipe: true)

        expect(solr_adapter.query_service.find_all.to_a.length).to eq 4
        expect(logger).to have_received(:error).with("Could not index #{resources[0].id}")
      end
    end
  end
end
