import SaveWorkControl from 'form/save_work_control'
import DuplicateResourceDetectorFactory from 'form/detect_duplicates'
import ServerUploader from "./server_uploader"
import StructureManager from "structure_manager"
import ModalViewer from "modal_viewer"
import DerivativeForm from "derivative_form"
import MetadataForm from "metadata_form"
import UniversalViewer from "universal_viewer"
import FileSetForm from "file_set_form"

export default class Initializer {
  constructor() {
    this.server_uploader = new ServerUploader
    this.initialize_form()
    this.initialize_timepicker()
    this.structure_manager = new StructureManager
    this.modal_viewer = new ModalViewer
    this.derivative_form = new DerivativeForm
    this.metadata_form = new MetadataForm
    this.universal_viewer = new UniversalViewer
    $("optgroup").addClass("closed")
    $("select").selectpicker({'liveSearch': true})
    $(".datatable").DataTable()
  }

  initialize_timepicker() {
    $(".timepicker").datetimepicker({
      timeFormat: "HH:mm:ssZ",
      separator: "T",
      dateFormat: "yy-mm-dd",
      timezone: "0",
      showTimezone: false,
      showHour: false,
      showMinute: false,
      showSecond: false,
      hourMax: 0,
      minuteMax: 0,
      secondMax: 0
    })
  }

  initialize_form() {
    if($("#form-progress").length > 0) {
      new SaveWorkControl($("#form-progress"))
    }

    $(".detect-duplicates").each((_i, element) =>
      DuplicateResourceDetectorFactory.build($(element))
    )

    $("form.edit_file_set.admin_controls").each((_i, element) =>
      new FileSetForm($(element))
    )
  }
}
