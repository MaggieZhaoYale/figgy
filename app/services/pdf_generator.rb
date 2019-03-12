# frozen_string_literal: true
class PDFGenerator
  class Error < StandardError; end

  attr_reader :resource, :storage_adapter
  def initialize(resource:, storage_adapter:)
    @resource = resource
    @storage_adapter = storage_adapter
  end

  # Use Prawn to capture the data downloaded from the Document in the PDF
  #   served from the IIIF Image Server
  # @return [FileMetadata] the FileMetadata Object node linked to the PDF
  # @raise [PDFGenerator::Error]
  def render
    CoverPageGenerator.new(self).apply(prawn_document)

    canvas_downloaders.each_with_index do |downloader, _index|
      prawn_document.start_new_page layout: downloader.layout
      page_size = [Canvas::LETTER_WIDTH, Canvas::LETTER_HEIGHT]
      page_size.reverse! unless downloader.portrait?
      # Handle errors where the download fails for a CanvasDownloader
      download_attempts = 0
      begin
        prawn_document.image downloader.download, width: page_size.first, height: page_size.last, fit: page_size
      rescue OpenURI::HTTPError => uri_error
        Valkyrie.logger.error "#{self.class}: Failed to download a PDF using the following URI as a base: #{downloader.download_url}: #{uri_error}"
        download_attempts += 1
        retry unless download_attempts > 4
        raise Error
      end
    end

    prawn_document.render_file(tmp_file.path)
    build_node
  rescue PDFGenerator::Canvas::InvalidIIIFManifestError => manifest_error
    Valkyrie.logger.error "#{self.class}: Failed to generate a PDF for the resource #{resource.id}: #{manifest_error}"
    raise Error
  end

  def build_node
    file = IngestableFile.new(file_path: tmp_file.path, mime_type: "application/pdf", original_filename: "derivative_pdf.pdf")
    node = FileMetadata.for(file: file).new(id: SecureRandom.uuid)
    stored_file = storage_adapter.upload(resource: node, file: file, original_filename: Array.wrap(node.original_filename).first)
    node.file_identifiers = stored_file.id
    node
  end

  def prawn_document
    @prawn_document ||= Prawn::Document.new(prawn_options)
  end

  def prawn_options
    default_options = { margin: 0 }
    default_options[:page_layout] = :portrait if canvas_downloaders.first
    default_options
  end

  # Construct the IIIF Manifest Object using the Figgy Resource
  # @return [Hash]
  def manifest
    @manifest ||= ManifestBuilder.new(resource).build
  end

  # Retrieve all of the IIIF Manifest Canvases in the first Sequence
  # @return [Hash]
  def manifest_canvases
    manifest["items"]
  end

  def canvas_image(canvas)
    annotation_pages = canvas["items"]
    return if annotation_pages.empty?

    annotations = annotation_pages.first["items"]
    valid_annotations = annotations.select { |anno| anno.key?("body") }
    return if valid_annotations.empty?

    valid_annotations.first["body"]
  end

  def manifest_images
    manifest_canvases.map { |canvas| canvas_image(canvas) }
  end

  # For each IIIF Manifest Canvas in the first Sequence, retrieve the first
  #   Image and use it to construct a Canvas Object
  # @return [Array<Canvas>]
  def canvas_images
    @canvas_images ||= manifest_images.map do |x|
      Canvas.new(x)
    end
  end

  def canvas_downloaders
    @canvas_images ||= canvas_images.map do |image|
      CanvasDownloader.new(image, quality: resource.pdf_type.first)
    end
  end

  def tmp_file
    @tmp_file ||= Tempfile.new("pdf")
  end
end
