class ZCL_ZSTC_TM_TASKLIST_DPC_EXT definition
  public
  inheriting from ZCL_ZSTC_TM_TASKLIST_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.

  methods SCENARIOSET_GET_ENTITY
    redefinition .
  methods SCENARIOSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZSTC_TM_TASKLIST_DPC_EXT IMPLEMENTATION.


  method SCENARIOSET_GET_ENTITYSET.

  DATA lt_scenarios type standard table of stc_s_scenario.
  DATA lt_returns   type standard table of bapiret2.

  DATA LV_SCENARIO_ID    TYPE STC_SCENARIO_ID.
  DATA lv_SCENARIO_DESCR TYPE STC_SCENARIO_DESCR.

  " Filter Logic
  DATA(it_filter_so) = io_tech_request_context->get_filter( )->get_filter_select_options( ).


  " ToDo: Implement several substring Filters
  " look at: https://community.sap.com/t5/technology-blog-posts-by-sap/how-to-get-select-options-for-a-filter-that-contains-two-substringof/ba-p/13356375

  "Filter Scenario ID
  "ScenarioId
  Data lt_filters_scenario_id   TYPE STC_RT_SCENARIO_ID.
  Data ls_filter_scenario_id    TYPE stc_rs_scenario_id.

  DATA(so_scenario_id) = VALUE /iwbep/t_cod_select_options( ).

  IF line_exists( it_filter_so[ property = 'SCENARIO_ID' ] ).
    so_scenario_id = it_filter_so[ property = 'SCENARIO_ID' ]-select_options.
  ENDIF.

  MOVE-CORRESPONDING so_scenario_id TO lt_filters_scenario_id.


  "Filter Scenario Description
  "ScenarioDescr
  Data lt_filters_scenario_descr TYPE STC_RT_SCENARIO_DESCR.
  Data ls_filter_scenario_descr    TYPE stc_rs_scenario_descr.

  DATA(so_scenario_descr) = VALUE /iwbep/t_cod_select_options( ).

  IF line_exists( it_filter_so[ property = 'SCENARIO_DESCR' ] ).
    so_scenario_descr = it_filter_so[ property = 'SCENARIO_DESCR' ]-select_options.
  ENDIF.

  MOVE-CORRESPONDING so_scenario_descr TO lt_filters_scenario_descr.

  "Filter AufgabenListen Gruppe
  "BasicScenId
  Data lt_filters_basic_scen_id TYPE STC_RT_BASIC_SCEN_ID.
  Data ls_filter_basics_scen_id TYPE stc_rs_basic_scen_id.

  DATA(so_basic_scen_id) = VALUE /iwbep/t_cod_select_options( ).

  IF line_exists( it_filter_so[ property = 'BASIC_SCEN_ID' ] ).
    so_basic_scen_id = it_filter_so[ property = 'BASIC_SCEN_ID' ]-select_options.
  ENDIF.

  MOVE-CORRESPONDING so_basic_scen_id TO lt_filters_basic_scen_id.

  CALL FUNCTION 'STC_TM_GET_SCENARIO_LIST'
    EXPORTING
        it_scenario_id      = lt_filters_scenario_id
        it_scenario_descr   = lt_filters_scenario_descr
        it_basic_scen_id    = lt_filters_basic_scen_id
    IMPORTING
        E_SCENARIO_ID       = lv_scenario_id
        E_SCENARIO_DESCR    = lv_scenario_descr
    TABLES
        ET_SCENARIO = lt_scenarios
        ET_RETURN   = lt_returns.

    IF lt_returns IS NOT INITIAL.
        mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_returns
                                                                      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
                message_container = mo_context->get_message_container( ).


    ENDIF.

    et_entityset = lt_scenarios.

  endmethod.


  method SCENARIOSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->SCENARIOSET_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.



  DATA lt_scenarios type standard table of stc_s_scenario.
  DATA lt_returns   type standard table of bapiret2.

  DATA LV_SCENARIO_ID    TYPE STC_SCENARIO_ID.
  DATA lv_SCENARIO_DESCR TYPE STC_SCENARIO_DESCR.

  " Filter Logic
  io_tech_request_context->get_converted_keys( IMPORTING es_key_values = er_entity ).


  "ScenarioId
  Data lt_filters_scenario_id   TYPE STC_RT_SCENARIO_ID.
  Data ls_filter_scenario_id    TYPE stc_rs_scenario_id.

  ls_filter_scenario_id-sign   = 'I'.
  ls_filter_scenario_id-option = 'EQ'.
  ls_filter_scenario_id-low    = er_entity-scenario_id.


  APPEND ls_filter_scenario_id TO lt_filters_scenario_id.


  CALL FUNCTION 'STC_TM_GET_SCENARIO_LIST'
    EXPORTING
        it_scenario_id      = lt_filters_scenario_id
    IMPORTING
        E_SCENARIO_ID       = lv_scenario_id
        E_SCENARIO_DESCR    = lv_scenario_descr
    TABLES
        ET_SCENARIO = lt_scenarios
        ET_RETURN   = lt_returns.

    IF lt_returns IS NOT INITIAL.
        mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_returns
                                                                      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
                message_container = mo_context->get_message_container( ).


    ENDIF.

    er_entity = lt_scenarios[ 1 ].

  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION.
    DATA: ls_task TYPE zcl_zstc_tm_tasklist_mpc=>ts_task,
          et_task TYPE zcl_zstc_tm_tasklist_mpc=>tt_task,
          ls_parameter TYPE /iwbep/s_mgw_name_value_pair.

    DATA lt_returns        type standard table of bapiret2.
    DATA LV_SCENARIO_ID    TYPE STC_SCENARIO_ID.
    DATA LV_TEMPLATE_ID    TYPE STC_TEMPLATE_ID.

    DATA lv_session_id     TYPE stc_session_id.
    DATA lv_taskname       TYPE stc_task_id.
    DATA lv_lnr            TYPE stc_task_lnr.

    DATA lv_skip_dep_tasks    TYPE sap_bool VALUE abap_false.
    DATA lv_unskip_dep_tasks  TYPE sap_bool VALUE abap_false.
    DATA lv_exec_failed_again TYPE sap_bool VALUE abap_false.

    DATA(lv_function_name) = io_tech_request_context->get_function_import_name( ).

    CASE lv_function_name.

      WHEN 'getTaskList'.
        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'ScenarioId'.
        IF sy-subrc = 0.
          lv_scenario_id = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'TemplateId'.
        IF sy-subrc = 0.
          lv_template_id = ls_parameter-value.
        ENDIF.

        CALL FUNCTION 'STC_TM_SCENARIO_GET_TASKLIST'
            EXPORTING
                i_scenario_id   = lv_scenario_id
                i_template_id   = lv_template_id
            IMPORTING
                et_tasklist     = et_task
            TABLES
                et_return       = lt_returns.

        IF lt_returns IS NOT INITIAL.
            mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_returns
                                                                      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                    message_container = mo_context->get_message_container( ).
        ENDIF.

        copy_data_to_ref( EXPORTING is_data = et_task
                          CHANGING cr_data = er_data ).

     WHEN 'ScenarioGetParameters'.
        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'ScenarioId'.
        IF sy-subrc = 0.
          lv_scenario_id = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'TemplateId'.
        IF sy-subrc = 0.
          lv_template_id = ls_parameter-value.
        ENDIF.

        Data et_task_value TYPE stctm_tx_value.
        Data et_task_definition TYPE stctm_tx_parameter.

        DATA lt_task_parameter TYPE STANDARD TABLE OF zcl_zstc_tm_tasklist_mpc=>ts_taskparameter.


        CALL FUNCTION 'STC_TM_SCENARIO_GET_PARAMETERS'
            EXPORTING
                i_scenario_id   = lv_scenario_id
                i_template_id   = lv_template_id
            IMPORTING
                et_parameter     = et_task_value
                et_param_def     = et_task_definition
            TABLES
                et_return       = lt_returns.

        IF lt_returns IS NOT INITIAL.
            mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_returns
                                                                      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                    message_container = mo_context->get_message_container( ).
        ENDIF.

        Data lv_found TYPE ABAP_BOOL VALUE abap_false.

        LOOP AT et_task_definition INTO DATA(ls_task_def).
            lv_found = abap_false.

            LOOP AT et_task_value INTO Data(ls_task_value).


                IF ls_task_def-taskname EQ ls_task_value-taskname
                    AND ls_task_def-lnr EQ ls_task_value-lnr
                    AND ls_task_def-fieldname EQ ls_task_value-fieldname.

                    lv_found = abap_true.
                    APPEND VALUE zcl_zstc_tm_tasklist_mpc=>ts_taskparameter(
                                                                    definition  = ls_task_def
                                                                    value       = ls_task_value
                                                                    scenario_id = lv_scenario_id
                                                                    template_id = lv_template_id
                                                                    session_id  = ''
                                                                    ) TO lt_task_parameter.

                ENDIF.
            ENDLOOP.

            IF lv_found EQ abap_false.
                Data ls_empty_value TYPE stctm_sx_value.
                APPEND VALUE zcl_zstc_tm_tasklist_mpc=>ts_taskparameter(
                                                                    definition  = ls_task_def
                                                                    value       = ls_empty_value
                                                                    scenario_id = lv_scenario_id
                                                                    template_id = lv_template_id
                                                                    session_id  = ''
                                                                    ) TO lt_task_parameter.
            ENDIF.

        ENDLOOP.


        copy_data_to_ref( EXPORTING is_data = lt_task_parameter
                          CHANGING cr_data = er_data ).

    WHEN 'confirmTask'.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'SessionId'.
        IF sy-subrc = 0.
          lv_session_id = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'Taskname'.
        IF sy-subrc = 0.
          lv_taskname = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'Lnr'.
        IF sy-subrc = 0.
          lv_lnr = ls_parameter-value.
        ENDIF.

        DATA ls_task_confirmed TYPE zcl_zstc_tm_tasklist_mpc=>confirmtaskreturn.

        CALL FUNCTION 'STC_TM_TASK_CONFIRM'
            EXPORTING
                i_session_id = lv_session_id
                i_taskname   = lv_taskname
                i_lnr        = lv_lnr
            IMPORTING
                e_confirmed = ls_task_confirmed-confirmed
            TABLES
                et_return = lt_returns.

        IF lt_returns IS NOT INITIAL.
            mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_returns
                                                                      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                    message_container = mo_context->get_message_container( ).
        ENDIF.

        copy_data_to_ref( EXPORTING is_data = ls_task_confirmed
                          CHANGING cr_data = er_data ).

    WHEN 'skipTask'.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'SessionId'.
        IF sy-subrc = 0.
          lv_session_id = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'Taskname'.
        IF sy-subrc = 0.
          lv_taskname = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'Lnr'.
        IF sy-subrc = 0.
          lv_lnr = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'skipDepTasks'.
        IF sy-subrc = 0.
          lv_skip_dep_tasks = ls_parameter-value.
        ENDIF.

        DATA ls_skip_task TYPE zcl_zstc_tm_tasklist_mpc=>skiptaskreturn.
        Data lt_task_skip_unskip_info TYPE stc_task_skip_unskip_info_t.

        CALL FUNCTION 'STC_TM_TASK_SKIP'
            EXPORTING
                i_session_id = lv_session_id
                i_taskname   = lv_taskname
                i_lnr        = lv_lnr
                i_skip_dep_tasks = lv_skip_dep_tasks
            IMPORTING
                e_skipped   = ls_skip_task-skipped
                et_skipped  = lt_task_skip_unskip_info
            TABLES
                et_return   = lt_returns.

        IF lt_returns IS NOT INITIAL AND lt_returns[ 1 ]-TYPE NE 'S'.
            mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_returns
                                                                      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                    message_container = mo_context->get_message_container( ).
        ENDIF.

        copy_data_to_ref( EXPORTING is_data = ls_skip_task
                          CHANGING cr_data = er_data ).

    WHEN 'unskipTask'.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'SessionId'.
        IF sy-subrc = 0.
          lv_session_id = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'Taskname'.
        IF sy-subrc = 0.
          lv_taskname = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'Lnr'.
        IF sy-subrc = 0.
          lv_lnr = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'unskipDepTasks'.
        IF sy-subrc = 0.
          lv_unskip_dep_tasks = ls_parameter-value.
        ENDIF.

        READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'execFailedAgain'.
        IF sy-subrc = 0.
          lv_exec_failed_again = ls_parameter-value.
        ENDIF.

        DATA ls_unskip_task TYPE zcl_zstc_tm_tasklist_mpc=>unskiptaskreturn.
        Data lt_task_unskip_unskip_info TYPE stc_task_skip_unskip_info_t.

        CALL FUNCTION 'STC_TM_TASK_UNSKIP'
            EXPORTING
                i_session_id = lv_session_id
                i_taskname   = lv_taskname
                i_lnr        = lv_lnr
                i_unskip_dep_tasks  = lv_unskip_dep_tasks
                i_exec_failed_again = lv_exec_failed_again
            IMPORTING
                e_unskipped   = ls_unskip_task-unskipped
                et_unskipped  = lt_task_unskip_unskip_info
            TABLES
                et_return   = lt_returns.

        IF lt_returns IS NOT INITIAL AND lt_returns[ 1 ]-TYPE NE 'S'.
            mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_returns
                                                                      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                    message_container = mo_context->get_message_container( ).
        ENDIF.

        copy_data_to_ref( EXPORTING is_data = ls_skip_task
                          CHANGING cr_data = er_data ).
    ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
*  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
*    IO_DATA_PROVIDER        =
**    it_key_tab              =
**    it_navigation_path      =
*    IO_EXPAND               =
**    io_tech_request_context =
**  IMPORTING
**    er_deep_entity          =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

    IF iv_entity_name EQ 'Session'.
        DATA: ls_session        TYPE zcl_zstc_tm_tasklist_mpc=>ts_session,
            ls_task_parameter   TYPE zcl_zstc_tm_tasklist_mpc=>ts_taskparameter,
            lt_task_parameter   TYPE STANDARD TABLE OF zcl_zstc_tm_tasklist_mpc=>ts_taskparameter,
            lt_fm_task_params   TYPE stctm_tx_value,
            lt_return           TYPE STANDARD TABLE OF bapiret2,
            ls_return           TYPE bapiret2.

        DATA: lr_deep_entity TYPE zcl_zstc_tm_tasklist_mpc_ext=>ts_session_deep.
        DATA: lv_is_exec_settings_empty TYPE abap_bool VALUE abap_false.


        io_data_provider->read_entry_data(
             IMPORTING
                es_data = lr_deep_entity ).

        MOVE-CORRESPONDING lr_deep_entity TO ls_session.
        lt_task_parameter = lr_deep_entity-totaskparameter.

        lv_is_exec_settings_empty = COND abap_bool( WHEN ls_session-exec_settings IS INITIAL
                                                         AND ( ls_session-exec_settings-CHECKRUN IS INITIAL
                                                            OR  ls_session-exec_settings-BATCH IS INITIAL
                                                            OR  ls_session-exec_settings-ASYNC IS INITIAL
                                                            OR  ls_session-exec_settings-TRACE IS INITIAL
                                                            OR ( ls_session-exec_settings-BATCH_TARGET IS INITIAL OR ls_session-exec_settings-BATCH_TARGET EQ '' )
                                                          )
                                                         THEN abap_true ).


        LOOP AT lt_task_parameter INTO ls_task_parameter.

            IF ls_task_parameter-value IS NOT INITIAL
                AND ls_task_parameter-value-fieldname IS NOT INITIAL
                AND ls_task_parameter-value-fieldname  NE ''.

                APPEND ls_task_parameter-value TO lt_fm_task_params.
            ENDIF.

        ENDLOOP.

        IF ls_session-scenario_id IS NOT INITIAL
            AND ( ls_session-session_id IS INITIAL OR ls_session-session_id EQ '' ).


            CALL FUNCTION 'STC_TM_SESSION_BEGIN'
                EXPORTING
                    i_scenario_id = lr_deep_entity-scenario_id
                    i_template_id = lr_deep_entity-template_id
                    i_init_only   = lr_deep_entity-init_only
                    it_parameter  = lt_fm_task_params
                IMPORTING
                    e_session_id  = lr_deep_entity-session_id
                    e_status      = lr_deep_entity-status
                    e_status_descr =  lr_deep_entity-status_descr
                    e_finalized   = lr_deep_entity-finalized
                    e_exec_id     = lr_deep_entity-exec_id
                TABLES
                    et_return = lt_return.

            " @TODO: lr_deep_entity-exec_id Timezone Type Conversion Problem
            "https://community.sap.com/t5/technology-blog-posts-by-sap/date-and-time-in-sap-gateway-foundation/bc-p/13327698

       ELSEIF ls_session-scenario_id IS NOT INITIAL
            AND ls_session-template_id IS NOT INITIAL
            AND ( ls_session-session_id IS NOT INITIAL OR ls_session-session_id NE '' )
            AND lv_is_exec_settings_empty EQ abap_true.



            Data lv_exec_id TYPE stc_exec_id.
            " IF Session for Tasklist already exist, then update the task parameter values
            CALL FUNCTION 'STC_TM_SESSION_SET_PARAMETERS'
              EXPORTING
                i_session_id = ls_session-session_id
                it_parameter = lt_fm_task_params
              TABLES
                et_return   = lt_return.

        ELSEIF ls_session-scenario_id IS INITIAL
            AND ls_session-template_id IS INITIAL
            AND ( ls_session-session_id IS INITIAL OR ls_session-session_id NE '' )
            AND lv_is_exec_settings_empty EQ abap_false.

            CALL FUNCTION 'STC_TM_SESSION_RESUME'
              EXPORTING
                i_session_id            = ls_session-session_id
                i_ignore_scenario_diff  = ls_session-ignore_scenario_diff
                it_parameter            = lt_fm_task_params
                is_exec_settings        = ls_session-exec_settings
              IMPORTING
                E_STATUS                = lr_deep_entity-status
                E_STATUS_DESCR          = lr_deep_entity-status_descr
                E_FINALIZED             = lr_deep_entity-finalized
                E_EXEC_ID               = lr_deep_entity-exec_id
              TABLES
                et_return   = lt_return.

        ELSE.

            DATA ls_error_detail TYPE  /iwbep/if_message_container=>ty_s_error_detail.


            ls_error_detail-code = 'STC_TM/064'.
            ls_error_detail-message_text = 'No appropiate function module could be found to the JSON payload'.
            ls_error_detail-severity = 'error'.

            mo_context->get_message_container( )->add_error_detail( is_error_detail = ls_error_detail ).

            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                    message_container = mo_context->get_message_container( ).


        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""
        "" Error Management
        """""""""""""""""""""""""""""""""""""""""""
        IF lt_return IS NOT INITIAL.
            mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_return
                                                                              iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).


            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                    message_container = mo_context->get_message_container( ).
        ENDIF.

        copy_data_to_ref(
             EXPORTING
                is_data = lr_deep_entity
             CHANGING
                cr_data = er_deep_entity
             ).
    ENDIF.



  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM.

    DATA: ls_file        TYPE zcl_zstc_tm_tasklist_mpc=>ts_log.
    DATA: ls_stream      TYPE ty_s_media_resource.
    DATA: lv_filename    TYPE skwf_filnm.

    DATA: lt_return           TYPE STANDARD TABLE OF bapiret2,
          ls_return           TYPE bapiret2.


  CASE io_tech_request_context->get_entity_type_name( ).

    WHEN zcl_zstc_tm_tasklist_mpc=>gc_log.

      io_tech_request_context->get_converted_keys( IMPORTING es_key_values = ls_file ).

      DATA lv_content_type type w3conttype.


      CALL FUNCTION 'STC_TM_SESSION_GET_LOG'
        EXPORTING
            i_session_id    = ls_file-session_id
        IMPORTING
            e_log           = ls_stream-value
            e_content_type  = lv_content_type
        TABLES
            et_return        = lt_return.


      """""""""""""""""""""""""""""""""""""""""""
      "" Error Management
      """""""""""""""""""""""""""""""""""""""""""
      IF lt_return IS NOT INITIAL.
            mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages = lt_return
                                                                              iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).


            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                    message_container = mo_context->get_message_container( ).
      ENDIF.

      ls_stream-mime_type = CONV STRING( lv_content_type ).
      lv_filename = | session_log_{ ls_file-session_id }|.

      " HTTP-Header-Infos (filename etc.)
      DATA(lv_lheader) = VALUE ihttpnvp( name  = 'Content-Disposition'
                                           value = |inline; filename="{ escape( val = lv_filename format = cl_abap_format=>e_url ) }";| ).
*                                           value = |outline; filename="{ escape( val = lv_filename format = cl_abap_format=>e_url ) }";| ). "for direct download
      set_header( is_header = lv_lheader ).

      DATA(lv_mime) = VALUE ihttpnvp( name  = 'Content-Type'
                                           value = 'application/xml').
      set_header( is_header = lv_mime ).



      me->copy_data_to_ref( EXPORTING is_data = ls_stream
                            CHANGING cr_data = er_stream ).


    WHEN OTHERS.

      super->/iwbep/if_mgw_appl_srv_runtime~get_stream(
        EXPORTING
          iv_entity_name          = iv_entity_name
          iv_entity_set_name      = iv_entity_set_name
          iv_source_name          = iv_source_name
          it_key_tab              = it_key_tab
          it_navigation_path      = it_navigation_path
          io_tech_request_context = io_tech_request_context
          IMPORTING
            er_stream             = er_stream
            es_response_context   = es_response_context ).
  ENDCASE.
  endmethod.
ENDCLASS.
