class ZOCT_FATOR_VENCIMENTO_BOLETO definition
  public
  final
  create public .

public section.

  types:
    fator(4) TYPE n .

  class-data DATA_BASE_1000 type SY-DATUM read-only value '20000703' ##NO_TEXT.
  class-data DATA_BASE_NOVA type SY-DATUM read-only value '20250222' ##NO_TEXT.
  class-data DATA_BASE_FEB type SY-DATUM read-only value '19971007' ##NO_TEXT.

  class-methods FATOR_TO_DATA
    importing
      value(IV_FATOR) type STRING
    returning
      value(RV_RESULT) type STRING .
  class-methods DATA_TO_FATOR
    importing
      value(IV_DATA) type DATUM
    exporting
      value(EX_FATOR) type FATOR .
protected section.
private section.

  class-methods CALC_FATOR
    importing
      value(IV_FATOR_DE_VENCIMENTO) type VTBBEWE-DBERBIS
      value(IV_DATA_FEBRABAN) type XFLAG optional
    returning
      value(RV_RESULT) type STRING .
ENDCLASS.



CLASS ZOCT_FATOR_VENCIMENTO_BOLETO IMPLEMENTATION.


  METHOD CALC_FATOR.
    DATA: lv_date_diff TYPE i,
          max_num(4) type n.

    IF iv_data_febraban = 'X'.
      CALL FUNCTION 'DAYS_BETWEEN_TWO_DATES'
        EXPORTING
          i_datum_bis = iv_fator_de_vencimento
          i_datum_von = zfi_fator_vencimento=>data_base_feb
        IMPORTING
          e_tage      = lv_date_diff.
      max_num = 9999.
    ELSE.
      lv_date_diff = iv_fator_de_vencimento - zfi_fator_vencimento=>data_base_1000 .
      max_num = 9000.
    ENDIF.

    rv_result = lv_date_diff.

    IF strlen( rv_result ) < 4.
      rv_result = condense( rv_result ).
      rv_result = lv_date_diff.
    ENDIF.

    WHILE lv_date_diff > max_num.
      lv_date_diff  = lv_date_diff  - 9000.
    ENDWHILE.

    rv_result = lv_date_diff.

  ENDMETHOD.


  METHOD DATA_TO_FATOR.
  ENDMETHOD.


  METHOD FATOR_TO_DATA.
    DATA: lv_data_calc_velho  TYPE sy-datum,
          lv_data_calc_novo   TYPE sy-datum,
          str_fator_hoje      TYPE string,
          str_fator_vencido   TYPE string,
          str_fator_avencer   TYPE string,
          str_fator_transicao TYPE string,
          dta_vencida         TYPE sy-datum,
          dta_avencer         TYPE sy-datum,
          data_base_nova      TYPE sy-datum,
          data_base_antiga    TYPE sy-datum,
          dta_hoje            TYPE sy-datum.

    dta_hoje = sy-datum.

    IF iv_fator > 0.
      dta_vencida = dta_hoje - 3000.
      dta_avencer = dta_hoje + 5500.

      str_fator_hoje = calc_fator( iv_fator_de_vencimento = dta_hoje iv_data_febraban = 'X' ).
      str_fator_vencido = str_fator_hoje - 3000.
      str_fator_avencer = str_fator_hoje + 5500.

      IF str_fator_vencido < 0.
        str_fator_vencido = str_fator_vencido + 9000.
      ENDIF.

      IF str_fator_avencer > 9999.
        str_fator_avencer = str_fator_avencer - 9000.
      ENDIF.

      IF str_fator_vencido > str_fator_avencer.
        str_fator_transicao = str_fator_vencido.
        str_fator_vencido = str_fator_avencer.
        str_fator_avencer = str_fator_transicao.
      ENDIF.

      lv_data_calc_velho = zfi_fator_vencimento=>data_base_1000 + ( iv_fator  - 1000 ).
      lv_data_calc_novo = zfi_fator_vencimento=>data_base_nova + (  iv_fator  - 1000 ).

      IF dta_vencida <= lv_data_calc_velho AND dta_avencer >= lv_data_calc_velho.
        rv_result = lv_data_calc_velho.
      ENDIF.

      IF dta_vencida <= lv_data_calc_novo AND dta_avencer >= lv_data_calc_novo.
        rv_result = lv_data_calc_novo.
      ENDIF.

      IF rv_result IS NOT INITIAL.
        rv_result = |{ rv_result(8) }|.
      ENDIF.

      IF  iv_fator  >  str_fator_vencido  AND iv_fator  <  str_fator_avencer.
        rv_result = ''.
      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
