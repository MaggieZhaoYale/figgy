# frozen_string_literal: true
require "rails_helper"

RSpec.describe ::BlacklightHelper do
  describe "#render_document_heading" do
    let(:model) { FactoryBot.build(:ephemera_term, id: "test", label: "Test") }
    let(:solr_document) { Valkyrie::MetadataAdapter.find(:index_solr).resource_factory.from_resource(resource: model) }
    let(:document) { SolrDocument.new(solr_document) }
    before do
      allow(helper).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
      allow(helper).to receive(:action_name).and_return("show")
    end
    context "when given an EphemeraTerm" do
      it "renders the label" do
        expect(helper.render_document_heading(document, tag: :h1)).to eq "<h1 itemprop=\"name\" dir=\"ltr\">Test</h1>"
      end
    end
    context "when given a Vocabulary" do
      let(:model) { FactoryBot.build(:ephemera_vocabulary, id: "test", label: "Test") }
      it "renders the label" do
        expect(helper.render_document_heading(document, tag: :h1)).to eq "<h1 itemprop=\"name\" dir=\"ltr\">Test</h1>"
      end
    end
    context "when given a value with RTL text" do
      let(:model) { FactoryBot.build(:ephemera_vocabulary, id: "test", label: "للفاسق") }
      it "renders the label" do
        expect(helper.render_document_heading(document, tag: :h1)).to eq "<h1 itemprop=\"name\" dir=\"rtl\">للفاسق</h1>"
      end
    end
    context "when given a resource with multiple titles" do
      let(:model) { FactoryBot.build(:scanned_resource, title: ["There and back again", "A hobbit's tale"]) }
      it "renders all titles, on separate lines" do
        expect(helper.render_document_heading(document, tag: :h1)).to eq "<h1 itemprop=\"name\" dir=\"ltr\">There and back again<br />A hobbit&#39;s tale</h1>"
      end
    end
  end
end
