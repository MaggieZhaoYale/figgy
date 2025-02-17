# frozen_string_literal: true
require "rails_helper"
require "cancan/matchers"

describe Ability do
  subject { described_class.new(current_user) }
  let(:page_file) { fixture_file_upload("files/example.tif", "image/tiff") }
  let(:page_file_2) { fixture_file_upload("files/example.tif", "image/tiff") }
  let(:shoulder) { "99999/fk4" }
  let(:blade) { "123456" }

  before do
    stub_ezid(shoulder: shoulder, blade: blade)
  end

  let(:open_scanned_resource) do
    FactoryBot.create_for_repository(:complete_open_scanned_resource, user: creating_user, title: "Open", files: [page_file])
  end

  let(:open_file) { open_scanned_resource.decorate.members.first }

  let(:open_file_set) do
    query_service.find_by(id: open_scanned_resource.member_ids.first)
  end

  let(:closed_file_set) do
    query_service.find_by(id: private_scanned_resource.member_ids.first)
  end

  let(:private_scanned_resource) do
    FactoryBot.create_for_repository(:complete_private_scanned_resource, title: "Private", user: creating_user, files: [page_file_2])
  end

  let(:campus_only_scanned_resource) do
    FactoryBot.create(:complete_campus_only_scanned_resource, title: "Campus Only", user: creating_user)
  end

  let(:reading_room_scanned_resource) do
    FactoryBot.create(:reading_room_scanned_resource, title: "Reading Room", user: creating_user)
  end

  let(:campus_ip_scanned_resource) do
    FactoryBot.create(:campus_ip_scanned_resource, title: "On Campus", user: creating_user)
  end

  let(:pending_scanned_resource) do
    FactoryBot.create(:pending_scanned_resource, title: "Pending", user: creating_user)
  end

  let(:metadata_review_scanned_resource) do
    FactoryBot.create(:metadata_review_scanned_resource, user: creating_user)
  end

  let(:final_review_scanned_resource) do
    FactoryBot.create(:final_review_scanned_resource, user: creating_user)
  end

  let(:complete_scanned_resource) do
    FactoryBot.create(:complete_scanned_resource, user: other_staff_user, identifier: ["ark:/99999/fk4445wg45"])
  end

  let(:takedown_scanned_resource) do
    FactoryBot.create(:takedown_scanned_resource, user: other_staff_user, identifier: ["ark:/99999/fk4445wg45"])
  end

  let(:flagged_scanned_resource) do
    FactoryBot.create(:flagged_scanned_resource, user: other_staff_user, identifier: ["ark:/99999/fk4445wg45"])
  end

  let(:staff_scanned_resource) do
    FactoryBot.create(:complete_scanned_resource, user: staff_user, identifier: ["ark:/99999/fk4445wg45"])
  end

  let(:file) { fixture_file_upload("files/example.tif") }
  let(:other_staff_scanned_resource) do
    FactoryBot.create_for_repository(:complete_scanned_resource, user: other_staff_user, identifier: ["ark:/99999/fk4445wg45"], files: [file])
  end

  let(:staff_file) { FactoryBot.build(:file_set, user: staff_user) }
  let(:other_staff_file) { other_staff_scanned_resource.decorate.members.first }
  let(:admin_file) { FactoryBot.build(:file_set, user: admin_user) }

  let(:admin_user) { FactoryBot.create(:admin) }
  let(:staff_user) { FactoryBot.create(:staff) }
  let(:other_staff_user) { FactoryBot.create(:staff) }
  let(:netid_user) { FactoryBot.create(:user) }
  let(:reading_room_user) { FactoryBot.create(:reading_room_user) }
  let(:role) { Role.where(name: "admin").first_or_create }

  describe "as an admin" do
    let(:admin_user) { FactoryBot.create(:admin) }
    let(:creating_user) { staff_user }
    let(:current_user) { admin_user }

    it {
      is_expected.to be_able_to(:create, ScannedResource.new)
      is_expected.to be_able_to(:create, FileSet.new)
      is_expected.to be_able_to(:read, open_scanned_resource)
      is_expected.to be_able_to(:read, private_scanned_resource)
      is_expected.to be_able_to(:read, takedown_scanned_resource)
      is_expected.to be_able_to(:read, flagged_scanned_resource)
      is_expected.to be_able_to(:read, reading_room_scanned_resource)
      is_expected.to be_able_to(:read, campus_ip_scanned_resource)
      is_expected.to be_able_to(:pdf, open_scanned_resource)
      is_expected.to be_able_to(:color_pdf, open_scanned_resource)
      is_expected.to be_able_to(:edit, open_scanned_resource)
      is_expected.to be_able_to(:edit, private_scanned_resource)
      is_expected.to be_able_to(:edit, takedown_scanned_resource)
      is_expected.to be_able_to(:edit, flagged_scanned_resource)
      is_expected.to be_able_to(:file_manager, open_scanned_resource)
      is_expected.to be_able_to(:update, open_scanned_resource)
      is_expected.to be_able_to(:update, private_scanned_resource)
      is_expected.to be_able_to(:update, takedown_scanned_resource)
      is_expected.to be_able_to(:update, flagged_scanned_resource)
      is_expected.to be_able_to(:destroy, open_scanned_resource)
      is_expected.to be_able_to(:destroy, private_scanned_resource)
      is_expected.to be_able_to(:destroy, takedown_scanned_resource)
      is_expected.to be_able_to(:destroy, flagged_scanned_resource)
      is_expected.to be_able_to(:manifest, open_scanned_resource)
      is_expected.to be_able_to(:manifest, pending_scanned_resource)
      is_expected.to be_able_to(:manifest, reading_room_scanned_resource)
      is_expected.to be_able_to(:manifest, campus_ip_scanned_resource)
      is_expected.to be_able_to(:discover, open_scanned_resource)
      is_expected.to be_able_to(:discover, pending_scanned_resource)
      is_expected.to be_able_to(:discover, reading_room_scanned_resource)
      is_expected.to be_able_to(:discover, campus_ip_scanned_resource)
      is_expected.to be_able_to(:read, :graphql)
    }

    context "when read-only mode is on" do
      before { allow(Figgy).to receive(:read_only_mode).and_return(true) }

      it {
        is_expected.not_to be_able_to(:create, ScannedResource.new)
        is_expected.not_to be_able_to(:create, FileSet.new)
        is_expected.to be_able_to(:read, open_scanned_resource)
        is_expected.to be_able_to(:read, private_scanned_resource)
        is_expected.to be_able_to(:read, takedown_scanned_resource)
        is_expected.to be_able_to(:read, flagged_scanned_resource)
        is_expected.not_to be_able_to(:pdf, open_scanned_resource)
        is_expected.not_to be_able_to(:color_pdf, open_scanned_resource)
        is_expected.not_to be_able_to(:edit, open_scanned_resource)
        is_expected.not_to be_able_to(:edit, private_scanned_resource)
        is_expected.not_to be_able_to(:edit, takedown_scanned_resource)
        is_expected.not_to be_able_to(:edit, flagged_scanned_resource)
        is_expected.not_to be_able_to(:file_manager, open_scanned_resource)
        is_expected.not_to be_able_to(:update, open_scanned_resource)
        is_expected.not_to be_able_to(:update, private_scanned_resource)
        is_expected.not_to be_able_to(:update, takedown_scanned_resource)
        is_expected.not_to be_able_to(:update, flagged_scanned_resource)
        is_expected.not_to be_able_to(:destroy, open_scanned_resource)
        is_expected.not_to be_able_to(:destroy, private_scanned_resource)
        is_expected.not_to be_able_to(:destroy, takedown_scanned_resource)
        is_expected.not_to be_able_to(:destroy, flagged_scanned_resource)
        is_expected.to be_able_to(:manifest, open_scanned_resource)
        is_expected.to be_able_to(:manifest, pending_scanned_resource)
        is_expected.to be_able_to(:discover, open_scanned_resource)
        is_expected.to be_able_to(:discover, pending_scanned_resource)
        is_expected.to be_able_to(:discover, reading_room_scanned_resource)
        is_expected.to be_able_to(:discover, campus_ip_scanned_resource)
        is_expected.to be_able_to(:read, :graphql)
      }
    end
  end

  describe "as a staff" do
    let(:creating_user) { other_staff_user }
    let(:current_user) { staff_user }

    it {
      is_expected.to be_able_to(:create, ScannedResource.new)
      is_expected.to be_able_to(:create, FileSet.new)
      is_expected.to be_able_to(:read, open_scanned_resource)
      is_expected.to be_able_to(:read, private_scanned_resource)
      is_expected.to be_able_to(:read, takedown_scanned_resource)
      is_expected.to be_able_to(:read, flagged_scanned_resource)
      is_expected.to be_able_to(:pdf, open_scanned_resource)
      is_expected.to be_able_to(:color_pdf, open_scanned_resource)
      is_expected.to be_able_to(:edit, open_scanned_resource)
      is_expected.to be_able_to(:edit, private_scanned_resource)
      is_expected.to be_able_to(:edit, takedown_scanned_resource)
      is_expected.to be_able_to(:edit, flagged_scanned_resource)
      is_expected.to be_able_to(:file_manager, open_scanned_resource)
      is_expected.to be_able_to(:update, open_scanned_resource)
      is_expected.to be_able_to(:update, private_scanned_resource)
      is_expected.to be_able_to(:update, takedown_scanned_resource)
      is_expected.to be_able_to(:update, flagged_scanned_resource)
      is_expected.to be_able_to(:destroy, staff_scanned_resource)
      is_expected.to be_able_to(:destroy, staff_file)
      is_expected.to be_able_to(:download, staff_file)
      is_expected.not_to be_able_to(:destroy, open_scanned_resource)
      is_expected.not_to be_able_to(:destroy, private_scanned_resource)
      is_expected.not_to be_able_to(:destroy, takedown_scanned_resource)
      is_expected.not_to be_able_to(:destroy, flagged_scanned_resource)
      is_expected.not_to be_able_to(:destroy, admin_file)
      is_expected.not_to be_able_to(:destroy, other_staff_file)
      is_expected.to be_able_to(:manifest, open_scanned_resource)
      is_expected.to be_able_to(:read, pending_scanned_resource)
      is_expected.to be_able_to(:manifest, pending_scanned_resource)
      is_expected.to be_able_to(:read, reading_room_scanned_resource)
      is_expected.to be_able_to(:manifest, reading_room_scanned_resource)
      is_expected.to be_able_to(:read, campus_ip_scanned_resource)
      is_expected.to be_able_to(:manifest, campus_ip_scanned_resource)
      is_expected.to be_able_to(:discover, open_scanned_resource)
      is_expected.to be_able_to(:discover, pending_scanned_resource)
      is_expected.to be_able_to(:discover, reading_room_scanned_resource)
      is_expected.to be_able_to(:discover, campus_ip_scanned_resource)
      is_expected.to be_able_to(:read, :graphql)
    }

    context "when read-only mode is on" do
      before { allow(Figgy).to receive(:read_only_mode).and_return(true) }

      it {
        is_expected.not_to be_able_to(:create, ScannedResource.new)
        is_expected.not_to be_able_to(:create, FileSet.new)
        is_expected.to be_able_to(:read, open_scanned_resource)
        is_expected.to be_able_to(:read, private_scanned_resource)
        is_expected.to be_able_to(:read, takedown_scanned_resource)
        is_expected.to be_able_to(:read, flagged_scanned_resource)
        is_expected.not_to be_able_to(:pdf, open_scanned_resource)
        is_expected.not_to be_able_to(:color_pdf, open_scanned_resource)
        is_expected.not_to be_able_to(:edit, open_scanned_resource)
        is_expected.not_to be_able_to(:edit, private_scanned_resource)
        is_expected.not_to be_able_to(:edit, takedown_scanned_resource)
        is_expected.not_to be_able_to(:edit, flagged_scanned_resource)
        is_expected.not_to be_able_to(:file_manager, open_scanned_resource)
        is_expected.not_to be_able_to(:update, open_scanned_resource)
        is_expected.not_to be_able_to(:update, private_scanned_resource)
        is_expected.not_to be_able_to(:update, takedown_scanned_resource)
        is_expected.not_to be_able_to(:update, flagged_scanned_resource)
        is_expected.not_to be_able_to(:destroy, staff_scanned_resource)
        is_expected.not_to be_able_to(:destroy, staff_file)
        is_expected.to be_able_to(:download, staff_file)
        is_expected.not_to be_able_to(:destroy, open_scanned_resource)
        is_expected.not_to be_able_to(:destroy, private_scanned_resource)
        is_expected.not_to be_able_to(:destroy, takedown_scanned_resource)
        is_expected.not_to be_able_to(:destroy, flagged_scanned_resource)
        is_expected.not_to be_able_to(:destroy, admin_file)
        is_expected.not_to be_able_to(:destroy, other_staff_file)
        is_expected.to be_able_to(:manifest, open_scanned_resource)
        is_expected.to be_able_to(:read, pending_scanned_resource)
        is_expected.to be_able_to(:manifest, pending_scanned_resource)
        is_expected.to be_able_to(:manifest, open_scanned_resource)
        is_expected.to be_able_to(:manifest, pending_scanned_resource)
        is_expected.to be_able_to(:discover, open_scanned_resource)
        is_expected.to be_able_to(:discover, pending_scanned_resource)
        is_expected.to be_able_to(:discover, reading_room_scanned_resource)
        is_expected.to be_able_to(:discover, campus_ip_scanned_resource)
        is_expected.to be_able_to(:read, :graphql)
      }
    end
  end

  describe "as a princeton netid user" do
    let(:creating_user) { staff_user }
    let(:current_user) { netid_user }

    it {
      is_expected.to be_able_to(:read, open_scanned_resource)
      is_expected.to be_able_to(:read, campus_only_scanned_resource)
      is_expected.to be_able_to(:read, complete_scanned_resource)
      is_expected.to be_able_to(:read, flagged_scanned_resource)
      is_expected.to be_able_to(:manifest, open_scanned_resource)
      is_expected.to be_able_to(:manifest, campus_only_scanned_resource)
      is_expected.to be_able_to(:manifest, complete_scanned_resource)
      is_expected.to be_able_to(:manifest, flagged_scanned_resource)
      is_expected.to be_able_to(:pdf, open_scanned_resource)
      is_expected.to be_able_to(:pdf, campus_only_scanned_resource)
      is_expected.to be_able_to(:pdf, complete_scanned_resource)
      is_expected.to be_able_to(:pdf, flagged_scanned_resource)
      is_expected.to be_able_to(:read, :graphql)
      is_expected.to be_able_to(:download, other_staff_file)

      is_expected.not_to be_able_to(:read, private_scanned_resource)
      is_expected.not_to be_able_to(:read, pending_scanned_resource)
      is_expected.not_to be_able_to(:read, metadata_review_scanned_resource)
      is_expected.not_to be_able_to(:read, final_review_scanned_resource)
      is_expected.not_to be_able_to(:read, takedown_scanned_resource)
      is_expected.not_to be_able_to(:read, reading_room_scanned_resource)
      is_expected.not_to be_able_to(:manifest, reading_room_scanned_resource)
      is_expected.not_to be_able_to(:read, campus_ip_scanned_resource)
      is_expected.not_to be_able_to(:manifest, campus_ip_scanned_resource)
      is_expected.not_to be_able_to(:file_manager, open_scanned_resource)
      is_expected.not_to be_able_to(:update, open_scanned_resource)
      is_expected.not_to be_able_to(:create, ScannedResource.new)
      is_expected.not_to be_able_to(:create, FileSet.new)
      is_expected.not_to be_able_to(:destroy, other_staff_file)
      is_expected.not_to be_able_to(:destroy, pending_scanned_resource)
      is_expected.not_to be_able_to(:destroy, complete_scanned_resource)
      is_expected.not_to be_able_to(:create, Role.new)
      is_expected.not_to be_able_to(:destroy, role)
      is_expected.not_to be_able_to(:complete, pending_scanned_resource)
      is_expected.not_to be_able_to(:destroy, admin_file)

      is_expected.to be_able_to(:discover, open_scanned_resource)
      is_expected.not_to be_able_to(:discover, pending_scanned_resource)
      is_expected.not_to be_able_to(:discover, reading_room_scanned_resource)
      is_expected.to be_able_to(:discover, campus_ip_scanned_resource)
    }

    context "when accessing figgy via a campus IP" do
      subject { described_class.new(current_user, ip_address: "128.112.0.0") }

      it {
        is_expected.to be_able_to(:read, campus_ip_scanned_resource)
        is_expected.to be_able_to(:manifest, campus_ip_scanned_resource)
      }
    end

    context "with a whitelisted reading room IP" do
      subject { described_class.new(current_user, ip_address: "1.2.3") }
      let(:config_hash) { { "access_control" => { "reading_room_ips" => ["1.2.3"] } } }
      before do
        allow(Figgy).to receive(:config).and_return(config_hash)
      end
      it {
        is_expected.not_to be_able_to(:read, reading_room_scanned_resource)
        is_expected.not_to be_able_to(:manifest, reading_room_scanned_resource)
        is_expected.to be_able_to(:discover, reading_room_scanned_resource)
      }
    end

    context "when read-only mode is on" do
      before { allow(Figgy).to receive(:read_only_mode).and_return(true) }

      it {
        is_expected.to be_able_to(:read, open_scanned_resource)
        is_expected.to be_able_to(:read, campus_only_scanned_resource)
        is_expected.to be_able_to(:read, complete_scanned_resource)
        is_expected.to be_able_to(:read, flagged_scanned_resource)
        is_expected.to be_able_to(:manifest, open_scanned_resource)
        is_expected.to be_able_to(:manifest, campus_only_scanned_resource)
        is_expected.to be_able_to(:manifest, complete_scanned_resource)
        is_expected.to be_able_to(:manifest, flagged_scanned_resource)
        is_expected.not_to be_able_to(:pdf, open_scanned_resource)
        is_expected.not_to be_able_to(:pdf, campus_only_scanned_resource)
        is_expected.not_to be_able_to(:pdf, complete_scanned_resource)
        is_expected.not_to be_able_to(:pdf, flagged_scanned_resource)
        is_expected.to be_able_to(:read, :graphql)
        is_expected.to be_able_to(:download, other_staff_file)

        is_expected.not_to be_able_to(:read, private_scanned_resource)
        is_expected.not_to be_able_to(:read, pending_scanned_resource)
        is_expected.not_to be_able_to(:read, metadata_review_scanned_resource)
        is_expected.not_to be_able_to(:read, final_review_scanned_resource)
        is_expected.not_to be_able_to(:read, takedown_scanned_resource)
        is_expected.not_to be_able_to(:file_manager, open_scanned_resource)
        is_expected.not_to be_able_to(:update, open_scanned_resource)
        is_expected.not_to be_able_to(:create, ScannedResource.new)
        is_expected.not_to be_able_to(:create, FileSet.new)
        is_expected.not_to be_able_to(:destroy, other_staff_file)
        is_expected.not_to be_able_to(:destroy, pending_scanned_resource)
        is_expected.not_to be_able_to(:destroy, complete_scanned_resource)
        is_expected.not_to be_able_to(:create, Role.new)
        is_expected.not_to be_able_to(:destroy, role)
        is_expected.not_to be_able_to(:complete, pending_scanned_resource)
        is_expected.not_to be_able_to(:destroy, admin_file)
      }
    end

    context "with a campus only vector resource" do
      let(:campus_only_vector_resource) { FactoryBot.create(:complete_campus_only_vector_resource, user: creating_user) }
      let(:adapter) { Valkyrie::MetadataAdapter.find(:indexing_persister) }
      let(:storage_adapter) { Valkyrie.config.storage_adapter }
      let(:persister) { adapter.persister }
      let(:query_service) { adapter.query_service }
      let(:file) { fixture_file_upload("files/vector/geo.json", "application/vnd.geo+json") }
      let(:change_set_persister) { ChangeSetPersister.new(metadata_adapter: adapter, storage_adapter: storage_adapter) }
      let(:vector_resource_members) { query_service.find_members(resource: vector_resource) }
      let(:file_set) { vector_resource_members.first }
      let(:vector_file) do
        DownloadsController::FileWithMetadata.new(id: "1234", file: "", mime_type: "application/vnd.geo+json", original_name: "file.geosjon", file_set_id: file_set.id)
      end
      let(:vector_resource) do
        change_set_persister.save(change_set: VectorResourceChangeSet.new(campus_only_vector_resource, files: [file]))
      end
      let(:shoulder) { "99999/fk4" }
      let(:blade) { "123456" }
      before do
        stub_ezid(shoulder: shoulder, blade: blade)
      end

      it {
        is_expected.to be_able_to(:download, vector_file)
      }
    end
  end

  describe "as a reading room user" do
    subject { described_class.new(current_user, ip_address: "1.2.3") }
    let(:creating_user) { staff_user }
    let(:current_user) { reading_room_user }

    context "without a whitelisted IP" do
      it {
        is_expected.not_to be_able_to(:read, reading_room_scanned_resource)
        is_expected.not_to be_able_to(:manifest, reading_room_scanned_resource)
        is_expected.not_to be_able_to(:discover, reading_room_scanned_resource)
      }
    end

    context "with a whitelisted IP" do
      let(:config_hash) { { "access_control" => { "reading_room_ips" => ["1.2.3"] } } }
      before do
        allow(Figgy).to receive(:config).and_return(config_hash)
      end
      it {
        is_expected.to be_able_to(:read, reading_room_scanned_resource)
        is_expected.to be_able_to(:manifest, reading_room_scanned_resource)
        is_expected.to be_able_to(:discover, reading_room_scanned_resource)
      }
    end
  end

  describe "as an anonymous user" do
    let(:creating_user) { staff_user }
    let(:current_user) { nil }
    let(:color_enabled_resource) do
      FactoryBot.build(:open_scanned_resource, user: creating_user, state: "complete", pdf_type: ["color"])
    end
    let(:no_pdf_scanned_resource) do
      FactoryBot.build(:open_scanned_resource, user: creating_user, state: "complete", pdf_type: [])
    end
    let(:ephemera_folder) { FactoryBot.create(:ephemera_folder, user: current_user) }
    let(:open_vector_resource) { FactoryBot.create(:complete_open_vector_resource, user: creating_user) }
    let(:private_vector_resource) { FactoryBot.create(:complete_private_vector_resource, user: creating_user) }
    let(:monogram) { FactoryBot.create(:numismatic_monogram) }
    let(:adapter) { Valkyrie::MetadataAdapter.find(:indexing_persister) }
    let(:storage_adapter) { Valkyrie.config.storage_adapter }
    let(:persister) { adapter.persister }
    let(:query_service) { adapter.query_service }
    let(:file) { fixture_file_upload("files/vector/geo.json", "application/vnd.geo+json") }
    let(:change_set_persister) { ChangeSetPersister.new(metadata_adapter: adapter, storage_adapter: storage_adapter) }
    let(:vector_resource_members) { query_service.find_members(resource: vector_resource) }
    let(:file_set) { vector_resource_members.first }
    let(:vector_file) do
      DownloadsController::FileWithMetadata.new(id: "1234", file: "", mime_type: "application/vnd.geo+json", original_name: "file.geosjon", file_set_id: file_set.id)
    end
    let(:metadata_file) do
      DownloadsController::FileWithMetadata.new(id: "5768", file: "", mime_type: "application/xml; schema=fgdc", original_name: "fgdc.xml", file_set_id: file_set.id)
    end
    let(:thumbnail_file) do
      DownloadsController::FileWithMetadata.new(id: "9abc", file: "", mime_type: "image/png", original_name: "thumbnail.png", file_set_id: file_set.id)
    end

    it {
      is_expected.to be_able_to(:read, open_scanned_resource)
      is_expected.to be_able_to(:read, open_file_set)
      is_expected.to be_able_to(:manifest, open_scanned_resource)
      is_expected.to be_able_to(:pdf, open_scanned_resource)
      is_expected.to be_able_to(:read, complete_scanned_resource)
      is_expected.to be_able_to(:manifest, complete_scanned_resource)
      is_expected.to be_able_to(:read, flagged_scanned_resource)
      is_expected.to be_able_to(:manifest, flagged_scanned_resource)
      is_expected.to be_able_to(:color_pdf, color_enabled_resource)
      is_expected.to be_able_to(:read, :graphql)
      is_expected.to be_able_to(:download, open_file)
      is_expected.to be_able_to(:read, monogram)
      is_expected.not_to be_able_to(:pdf, no_pdf_scanned_resource)
      is_expected.not_to be_able_to(:flag, open_scanned_resource)
      is_expected.not_to be_able_to(:read, campus_only_scanned_resource)
      is_expected.not_to be_able_to(:read, private_scanned_resource)
      is_expected.not_to be_able_to(:read, pending_scanned_resource)
      is_expected.not_to be_able_to(:read, metadata_review_scanned_resource)
      is_expected.not_to be_able_to(:read, final_review_scanned_resource)
      is_expected.not_to be_able_to(:read, takedown_scanned_resource)
      is_expected.not_to be_able_to(:read, reading_room_scanned_resource)
      is_expected.not_to be_able_to(:manifest, reading_room_scanned_resource)
      is_expected.not_to be_able_to(:manifest, ephemera_folder)
      is_expected.not_to be_able_to(:file_manager, open_scanned_resource)
      is_expected.not_to be_able_to(:update, open_scanned_resource)
      is_expected.not_to be_able_to(:create, ScannedResource.new)
      is_expected.not_to be_able_to(:create, FileSet.new)
      is_expected.not_to be_able_to(:destroy, other_staff_file)
      is_expected.not_to be_able_to(:destroy, pending_scanned_resource)
      is_expected.not_to be_able_to(:destroy, complete_scanned_resource)
      is_expected.not_to be_able_to(:create, Role.new)
      is_expected.not_to be_able_to(:destroy, role)
      is_expected.not_to be_able_to(:complete, pending_scanned_resource)
      is_expected.not_to be_able_to(:destroy, admin_file)

      is_expected.to be_able_to(:discover, open_scanned_resource)
      is_expected.not_to be_able_to(:discover, private_scanned_resource)
      is_expected.not_to be_able_to(:discover, pending_scanned_resource)
      is_expected.not_to be_able_to(:discover, reading_room_scanned_resource)
      is_expected.to be_able_to(:discover, campus_ip_scanned_resource)
    }

    context "when accessing figgy via a campus IP" do
      subject { described_class.new(current_user, ip_address: "128.112.0.0") }

      it {
        is_expected.to be_able_to(:read, campus_ip_scanned_resource)
        is_expected.to be_able_to(:manifest, campus_ip_scanned_resource)
      }
    end

    context "when read-only mode is on" do
      before { allow(Figgy).to receive(:read_only_mode).and_return(true) }

      it {
        is_expected.to be_able_to(:read, open_scanned_resource)
        is_expected.to be_able_to(:read, open_file_set)
        is_expected.to be_able_to(:manifest, open_scanned_resource)
        is_expected.not_to be_able_to(:pdf, open_scanned_resource)
        is_expected.to be_able_to(:read, complete_scanned_resource)
        is_expected.to be_able_to(:manifest, complete_scanned_resource)
        is_expected.to be_able_to(:read, flagged_scanned_resource)
        is_expected.to be_able_to(:manifest, flagged_scanned_resource)
        is_expected.not_to be_able_to(:color_pdf, color_enabled_resource)
        is_expected.to be_able_to(:read, :graphql)
        is_expected.to be_able_to(:download, open_file)
        is_expected.not_to be_able_to(:pdf, no_pdf_scanned_resource)
        is_expected.not_to be_able_to(:flag, open_scanned_resource)
        is_expected.not_to be_able_to(:read, campus_only_scanned_resource)
        is_expected.not_to be_able_to(:read, private_scanned_resource)
        is_expected.not_to be_able_to(:read, pending_scanned_resource)
        is_expected.not_to be_able_to(:read, metadata_review_scanned_resource)
        is_expected.not_to be_able_to(:read, final_review_scanned_resource)
        is_expected.not_to be_able_to(:read, takedown_scanned_resource)
        is_expected.not_to be_able_to(:manifest, ephemera_folder)
        is_expected.not_to be_able_to(:file_manager, open_scanned_resource)
        is_expected.not_to be_able_to(:update, open_scanned_resource)
        is_expected.not_to be_able_to(:create, ScannedResource.new)
        is_expected.not_to be_able_to(:create, FileSet.new)
        is_expected.not_to be_able_to(:destroy, other_staff_file)
        is_expected.not_to be_able_to(:destroy, pending_scanned_resource)
        is_expected.not_to be_able_to(:destroy, complete_scanned_resource)
        is_expected.not_to be_able_to(:create, Role.new)
        is_expected.not_to be_able_to(:destroy, role)
        is_expected.not_to be_able_to(:complete, pending_scanned_resource)
        is_expected.not_to be_able_to(:destroy, admin_file)
      }
    end

    context "with an open vector resource" do
      let(:vector_resource) do
        change_set_persister.save(change_set: VectorResourceChangeSet.new(open_vector_resource, files: [file]))
      end
      let(:shoulder) { "99999/fk4" }
      let(:blade) { "123456" }
      before do
        stub_ezid(shoulder: shoulder, blade: blade)
      end

      it {
        is_expected.to be_able_to(:download, file_set)
        is_expected.to be_able_to(:download, thumbnail_file)
        is_expected.to be_able_to(:download, metadata_file)
        is_expected.to be_able_to(:download, vector_file)
      }
    end

    context "with a private vector resource" do
      let(:vector_resource) do
        change_set_persister.save(change_set: VectorResourceChangeSet.new(private_vector_resource, files: [file]))
      end
      let(:shoulder) { "99999/fk4" }
      let(:blade) { "123456" }
      before do
        stub_ezid(shoulder: shoulder, blade: blade)
      end

      it {
        is_expected.to be_able_to(:download, file_set)
        is_expected.to be_able_to(:download, thumbnail_file)
        is_expected.to be_able_to(:download, metadata_file)
        is_expected.not_to be_able_to(:download, vector_file)
      }
    end
  end

  describe "token auth" do
    subject(:ability) { described_class.new(nil, auth_token: token) }

    let(:creating_user) { admin_user }
    let(:private_vector_resource) { FactoryBot.create(:complete_private_vector_resource, user: creating_user) }
    let(:adapter) { Valkyrie::MetadataAdapter.find(:indexing_persister) }
    let(:storage_adapter) { Valkyrie.config.storage_adapter }
    let(:file) { fixture_file_upload("files/vector/geo.json", "application/vnd.geo+json") }
    let(:change_set_persister) { ChangeSetPersister.new(metadata_adapter: adapter, storage_adapter: storage_adapter) }
    let(:vector_resource) do
      change_set_persister.save(change_set: VectorResourceChangeSet.new(private_vector_resource, files: [file]))
    end

    context "with an auth token" do
      let(:token) { AuthToken.create(label: "Test", group: ["admin"]).token }

      it "uses the auth token" do
        expect(ability.current_user.admin?).to be true
      end

      it "provides access to a resource" do
        is_expected.to be_able_to(:read, vector_resource)
      end
    end

    context "without an auth token" do
      let(:token) { nil }

      before do
        allow(AuthToken).to receive(:find_by).and_call_original
      end

      it "is anonymous" do
        expect(ability.current_user.admin?).to be false
        expect(ability.current_user.anonymous?).to be true
        expect(AuthToken).not_to have_received(:find_by)
      end

      it "preserves the access controls to a resource" do
        is_expected.not_to be_able_to(:read, vector_resource)
      end
    end

    context "when read-only mode is on" do
      before { allow(Figgy).to receive(:read_only_mode).and_return(true) }
      let(:token) { AuthToken.create(label: "Test", group: ["admin"]).token }

      it "provides access to a resource" do
        is_expected.to be_able_to(:read, vector_resource)
      end

      it "prohibits write access to a resource" do
        is_expected.not_to be_able_to(:update, vector_resource)
        is_expected.not_to be_able_to(:create, vector_resource)
        is_expected.not_to be_able_to(:destroy, vector_resource)
      end
    end
  end
end
