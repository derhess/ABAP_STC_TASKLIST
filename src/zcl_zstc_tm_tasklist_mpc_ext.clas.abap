class ZCL_ZSTC_TM_TASKLIST_MPC_EXT definition
  public
  inheriting from ZCL_ZSTC_TM_TASKLIST_MPC
  create public .

public section.

  types:
    BEGIN OF ts_session_deep,
        scenario_id              TYPE  stc_scenario_id,
        template_id              TYPE  stc_template_id,
        init_only                TYPE sap_bool,
        ignore_langu_diff        TYPE  sap_bool,
        ignore_scenario_diff     TYPE  sap_bool,
        ignore_scenario_obsolete TYPE  sap_bool,
        exec_settings            TYPE  stc_exec_settings,
        caller_info              TYPE  stc_ext_caller_info,
        status                   TYPE  stc_session_status,
        status_descr             TYPE stc_session_status_descr,
        finalized                TYPE stc_session_finalized,
        exec_id                  TYPE stc_exec_id,
        session_id               TYPE STC_SESSION_ID,
        ToTaskParameter  TYPE STANDARD TABLE OF ZSTC_S_TASKPARAM WITH DEFAULT KEY,
    END OF ts_session_deep .

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZSTC_TM_TASKLIST_MPC_EXT IMPLEMENTATION.


  method DEFINE.
    super->define( ).

    DATA:
        lo_annotation     TYPE REF TO /iwbep/if_mgw_odata_annotation,
        lo_entity_type    TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
        lo_complex_type   TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,
        lo_property       TYPE REF TO /iwbep/if_mgw_odata_property,
        lo_entity_set     TYPE REF TO /iwbep/if_mgw_odata_entity_set.

    DATA: lo_session_log_entity     TYPE REF TO /iwbep/if_mgw_odata_entity_typ.
    DATA: lo_session_log_property   TYPE REF TO /iwbep/if_mgw_odata_property.


    "******************************************************************  *****************************************************************
    "*   ENTITY - Deep Entity
    "******************************************************************  *****************************************************************

    lo_entity_type = model->get_entity_type( iv_entity_name = 'Session' ). "#EC NOTEXT
    lo_entity_type->bind_structure( iv_structure_name  =    'ZCL_ZSTC_TM_TASKLIST_MPC_EXT=>TS_SESSION_DEEP' )."#EC NOTEXT

    "******************************************************************  *****************************************************************
    "*   ENTITY - Binary File
    "******************************************************************  *****************************************************************
    lo_session_log_entity = model->get_entity_type( iv_entity_name = ZCL_ZSTC_TM_TASKLIST_MPC_EXT=>gc_log ).
    lo_property = lo_session_log_entity->get_property( iv_property_name = 'MimeType' ).
    lo_property->set_as_content_type( ).

  endmethod.
ENDCLASS.
