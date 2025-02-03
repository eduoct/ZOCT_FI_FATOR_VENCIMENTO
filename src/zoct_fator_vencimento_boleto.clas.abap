CLASS zoct_fator_vencimento_boleto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: ty_fator(4) TYPE n.

    CLASS-DATA gv_data_base_1000 TYPE sy-datum READ-ONLY VALUE '20000703' ##NO_TEXT.
    CLASS-DATA gv_data_base_nova TYPE sy-datum READ-ONLY VALUE '20250222' ##NO_TEXT.
    CLASS-DATA gv_data_base_feb TYPE sy-datum READ-ONLY VALUE '19971007' ##NO_TEXT.

    CLASS-METHODS fator_to_data
    IMPORTING iv_fator       TYPE string
    RETURNING VALUE(rv_date) TYPE string .

    CLASS-METHODS data_to_fator
    IMPORTING iv_data         TYPE sy-datum
    RETURNING VALUE(rv_fator) TYPE ty_fator.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS calc_fator
    IMPORTING iv_fator_de_vencimento TYPE sy-datum
      iv_data_febraban               TYPE abap_bool OPTIONAL
    RETURNING VALUE(rv_result)       TYPE string .
ENDCLASS.



CLASS zoct_fator_vencimento_boleto IMPLEMENTATION.


  METHOD calc_fator.
    DATA: lv_date_diff TYPE i,
          lv_max_num(4) TYPE n.

    IF iv_data_febraban = 'X'.
      CALL FUNCTION 'DAYS_BETWEEN_TWO_DATES'
        EXPORTING
          i_datum_bis = iv_fator_de_vencimento
          i_datum_von = gv_data_base_feb
        IMPORTING
          e_tage      = lv_date_diff.
      lv_max_num = 9999.
    ELSE.
      lv_date_diff = iv_fator_de_vencimento - gv_data_base_1000.
      lv_max_num = 9000.
    ENDIF.

    rv_result = lv_date_diff.

    IF strlen( rv_result ) < 4.
      rv_result = condense( rv_result ).
      rv_result = lv_date_diff.
    ENDIF.

    WHILE lv_date_diff > lv_max_num.
      lv_date_diff  = lv_date_diff  - 9000.
    ENDWHILE.

    rv_result = lv_date_diff.

  ENDMETHOD.


  METHOD data_to_fator.
  ENDMETHOD.


  METHOD fator_to_data.
    DATA: lv_data_calc_velho  TYPE sy-datum,
          lv_data_calc_novo   TYPE sy-datum,
          lv_str_fator_hoje      TYPE string,
          lv_str_fator_vencido   TYPE string,
          lv_str_fator_avencer   TYPE string,
          lv_str_fator_transicao TYPE string,
          lv_dta_vencida         TYPE sy-datum,
          lv_dta_avencer         TYPE sy-datum,
          lv_dta_hoje            TYPE sy-datum.

    lv_dta_hoje = sy-datum.

    IF iv_fator > 0.
      lv_dta_vencida = lv_dta_hoje - 3000.
      lv_dta_avencer = lv_dta_hoje + 5500.

      lv_str_fator_hoje = calc_fator( iv_fator_de_vencimento = lv_dta_hoje
                                      iv_data_febraban = 'X' ).
      lv_str_fator_vencido = lv_str_fator_hoje - 3000.
      lv_str_fator_avencer = lv_str_fator_hoje + 5500.

      IF lv_str_fator_vencido < 0.
        lv_str_fator_vencido = lv_str_fator_vencido + 9000.
      ENDIF.

      IF lv_str_fator_avencer > 9999.
        lv_str_fator_avencer = lv_str_fator_avencer - 9000.
      ENDIF.

      IF lv_str_fator_vencido > lv_str_fator_avencer.
        lv_str_fator_transicao = lv_str_fator_vencido.
        lv_str_fator_vencido = lv_str_fator_avencer.
        lv_str_fator_avencer = lv_str_fator_transicao.
      ENDIF.

      lv_data_calc_velho = gv_data_base_1000 + ( iv_fator  - 1000 ).
      lv_data_calc_novo = gv_data_base_nova + (  iv_fator  - 1000 ).

      IF lv_dta_vencida <= lv_data_calc_velho AND lv_dta_avencer >= lv_data_calc_velho.
        rv_date = lv_data_calc_velho.
      ENDIF.

      IF lv_dta_vencida <= lv_data_calc_novo AND lv_dta_avencer >= lv_data_calc_novo.
        rv_date = lv_data_calc_novo.
      ENDIF.

      IF rv_date IS NOT INITIAL.
        rv_date = |{ rv_date(8) }|.
      ENDIF.

      IF iv_fator  > lv_str_fator_vencido  AND iv_fator  < lv_str_fator_avencer.
        rv_date = ''.
      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
