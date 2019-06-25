# frozen_string_literal: true
class PulfaExporter
  attr_reader :since_date, :svn_client, :logger
  def initialize(svn_dir:, since_date:, logger: Logger.new(STDOUT), svn_client: nil)
    @logger = logger
    @since_date = since_date

    svn_base = Figgy.config["pulfa"]["svn_base"]
    @svn_client = svn_client || SvnClient.new(svn_base: svn_base, svn_dir: svn_dir)
  end

  def export
    svn_client.switch("trunk")
    svn_client.update
    export_branch(group: "mudd", include: "/mudd/")
    export_branch(group: "mss", exclude: "/mudd/")
  end

  private

    def updated_objects
      logger.info "Listing objects updated since #{since_date}"
      @updated_objects ||= Valkyrie.config.metadata_adapter.query_service.custom_queries.updated_archival_resources(since_date: since_date)
      @updated_objects
    end

    def grouped_objects
      @grouped_objects ||= updated_objects.group_by(&:archival_collection_code)
    end

    def export_branch(group:, include: nil, exclude: nil)
      logger.info "Exporting #{group}"
      url = svn_client.create_branch(group)
      export_only(include) if include
      export_except(exclude) if exclude
      svn_client.commit
      notify(group, url)
    end

    # export everything where the file starts with pattern
    def export_only(pattern)
      grouped_objects.keys.each do |collection_code|
        file = ead_for(collection_code)
        update_ead(file, grouped_objects[collection_code]) if file && file.include?(pattern)
      end
    end

    # export everything where the file doesn't start with pattern
    def export_except(pattern)
      grouped_objects.keys.each do |collection_code|
        file = ead_for(collection_code)
        update_ead(file, grouped_objects[collection_code]) unless !file || file.include?(pattern)
      end
    end

    # find the EAD file for a collection code
    def ead_for(collection_code)
      all_eads.select { |fn| fn.include?("/#{collection_code}.EAD.xml") }.first
    end

    # list all EAD/XML files
    def all_eads
      @all_eads ||= Dir["#{svn_client.svn_dir}/eads/**/*.EAD.xml"]
    end

    # update the DAO links in an EAD/XML file
    def update_ead(filename, resources)
      logger.info "Updating DAO URLs in #{filename}"
      ead = Nokogiri::XML(File.open(filename))

      resources.each do |r|
        cid = r.source_metadata_identifier.first
        component = ead.at_xpath("//ead:c[@id=\'#{cid}\']", namespaces_for_xpath)
        create_or_update_dao(ead, component, r) if component
      end

      File.open(filename, "w") { |f| f.puts(ead.to_xml) }
    end

    def create_or_update_dao(ead, component, r)
      dao = component.at_xpath(".//ead:dao", namespaces_for_xpath) || create_dao_element(ead, component)

      dao.attribute_nodes.each(&:remove)
      dao.set_attribute("xlink:href", Rails.application.routes.url_helpers.manifest_scanned_resource_url(r))
      dao.set_attribute("xlink:type", "simple")
      dao.set_attribute("xlink:role", "https://iiif.io/api/presentation/2.1/")
    end

    # create and attach a new dao element
    def create_dao_element(ead, component)
      did = component.at_xpath("./ead:did", namespaces_for_xpath)
      new_dao = Nokogiri::XML::Element.new("dao", ead)
      did.add_child(new_dao)
    end

    def namespaces_for_xpath
      { xlink: "http://www.w3.org/1999/xlink", ead: "urn:isbn:1-931666-22-9" }
    end

    # send email to configured address about branch being ready to review
    def notify(group, url)
      PulfaMailer.with(group: group, url: url).branch_notification.deliver_now
    end
end
