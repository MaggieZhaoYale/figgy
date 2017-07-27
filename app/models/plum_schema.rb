# frozen_string_literal: true
module PlumSchema
  extend ActiveSupport::Concern
  def imported_schema
    [
      # Hyrax,
      :depositor,
      :title,
      :label,
      :visibility,

      :relative_path,

      :import_url,

      :part_of,
      :resource_type,
      :creator,
      :contributor,
      :description,
      :keyword,
      # Used for a license,
      :license,

      # This is for the rights statement,
      :publisher,
      :date_created,
      :subject,
      :language,
      :based_near,
      :related_url,
      :bibliographic_citation,
      # Generated from Context,
      :coverage,
      :created,
      :date,
      :format,
      :source,
      :extent,
      :edition,
      :cartographic_scale,
      :call_number,
      :abridger,
      :actor,
      :adapter,
      :addressee,
      :analyst,
      :animator,
      :annotator,
      :appellant,
      :appellee,
      :applicant,
      :architect,
      :arranger,
      :art_copyist,
      :art_director,
      :artist,
      :artistic_director,
      :assignee,
      :associated_name,
      :attributed_name,
      :auctioneer,
      :author,
      :author_in_quotations_or_text_abstracts,
      :author_of_afterword_colophon_etc,
      :author_of_dialog,
      :author_of_introduction_etc,
      :autographer,
      :bibliographic_antecedent,
      :binder,
      :binding_designer,
      :blurb_writer,
      :book_designer,
      :book_producer,
      :bookjacket_designer,
      :bookplate_designer,
      :bookseller,
      :braille_embosser,
      :broadcaster,
      :calligrapher,
      :cartographer,
      :caster,
      :censor,
      :choreographer,
      :cinematographer,
      :client,
      :collection_registrar,
      :collector,
      :collotyper,
      :colorist,
      :commentator,
      :commentator_for_written_text,
      :compiler,
      :complainant,
      :complainant_appellant,
      :complainant_appellee,
      :composer,
      :compositor,
      :conceptor,
      :conductor,
      :conservator,
      :consultant,
      :consultant_to_a_project,
      :contestant,
      :contestant_appellant,
      :contestant_appellee,
      :contestee,
      :contestee_appellant,
      :contestee_appellee,
      :contractor,
      :copyright_claimant,
      :copyright_holder,
      :corrector,
      :correspondent,
      :costume_designer,
      :court_governed,
      :court_reporter,
      :cover_designer,
      :curator,
      :dancer,
      :data_contributor,
      :data_manager,
      :dedicatee,
      :dedicator,
      :defendant,
      :defendant_appellant,
      :defendant_appellee,
      :degree_granting_institution,
      :degree_supervisor,
      :delineator,
      :depicted,
      :designer,
      :director,
      :dissertant,
      :distribution_place,
      :distributor,
      :donor,
      :draftsman,
      :dubious_author,
      :editor,
      :editor_of_compilation,
      :editor_of_moving_image_work,
      :electrician,
      :electrotyper,
      :enacting_jurisdiction,
      :engineer,
      :engraver,
      :etcher,
      :event_place,
      :expert,
      :facsimilist,
      :field_director,
      :film_distributor,
      :film_director,
      :film_editor,
      :film_producer,
      :filmmaker,
      :first_party,
      :forger,
      :former_owner,
      :funder,
      :geographic_information_specialist,
      :honoree,
      :host,
      :host_institution,
      :illuminator,
      :illustrator,
      :inscriber,
      :instrumentalist,
      :interviewee,
      :interviewer,
      :inventor,
      :issuing_body,
      :judge,
      :jurisdiction_governed,
      :laboratory,
      :laboratory_director,
      :landscape_architect,
      :lead,
      :lender,
      :libelant,
      :libelant_appellant,
      :libelant_appellee,
      :libelee,
      :libelee_appellant,
      :libelee_appellee,
      :librettist,
      :licensee,
      :licensor,
      :lighting_designer,
      :lithographer,
      :lyricist,
      :manufacture_place,
      :manufacturer,
      :marbler,
      :markup_editor,
      :medium,
      :metadata_contact,
      :metal_engraver,
      :minute_taker,
      :moderator,
      :monitor,
      :music_copyist,
      :musical_director,
      :musician,
      :narrator,
      :onscreen_presenter,
      :opponent,
      :organizer,
      :originator,
      :other,
      :owner,
      :panelist,
      :papermaker,
      :patent_applicant,
      :patent_holder,
      :patron,
      :performer,
      :permitting_agency,
      :photographer,
      :plaintiff,
      :plaintiff_appellant,
      :plaintiff_appellee,
      :platemaker,
      :praeses,
      :presenter,
      :printer,
      :printer_of_plates,
      :printmaker,
      :process_contact,
      :producer,
      :production_company,
      :production_designer,
      :production_manager,
      :production_personnel,
      :production_place,
      :programmer,
      :project_director,
      :proofreader,
      :provider,
      :publication_place,
      :publishing_director,
      :puppeteer,
      :radio_director,
      :radio_producer,
      :recording_engineer,
      :recordist,
      :redaktor,
      :renderer,
      :reporter,
      :marc_repository,
      :research_team_head,
      :research_team_member,
      :researcher,
      :respondent,
      :respondent_appellant,
      :respondent_appellee,
      :responsible_party,
      :restager,
      :restorationist,
      :reviewer,
      :rubricator,
      :scenarist,
      :scientific_advisor,
      :screenwriter,
      :scribe,
      :sculptor,
      :second_party,
      :secretary,
      :seller,
      :set_designer,
      :setting,
      :signer,
      :singer,
      :sound_designer,
      :speaker,
      :sponsor,
      :stage_director,
      :stage_manager,
      :standards_body,
      :stereotyper,
      :storyteller,
      :supporting_host,
      :surveyor,
      :teacher,
      :technical_director,
      :television_director,
      :television_producer,
      :thesis_advisor,
      :transcriber,
      :translator,
      :type_designer,
      :typographer,
      :university_place,
      :videographer,
      :voice_actor,
      :witness,
      :wood_engraver,
      :woodcutter,
      :writer_of_accompanying_material,
      :writer_of_added_commentary,
      :writer_of_added_text,
      :writer_of_added_lyrics,
      :writer_of_supplementary_textual_content,
      :writer_of_introduction,
      :writer_of_preface
    ]
  end

  def local_schema
    [
      # Plum,
      :sort_title,
      :portion_note,
      :abstract,
      :alternative,
      :identifier,
      :local_identifier,
      :replaces,
      :contents,
      :rights_statement,
      :rights_note,
      :source_metadata_identifier,
      :source_metadata,
      :source_jsonld,
      :holding_location,
      :ocr_language,
      :nav_date,
      :pdf_type,
      :start_canvas,
      :container,
      :thumbnail_id
    ]
  end

  def schema
    imported_schema + local_schema
  end
  module_function :schema, :imported_schema, :local_schema

  included do
    PlumSchema.schema.each do |field|
      attribute field
    end
  end
end
