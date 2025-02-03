CLASS zoct_fator_vencimento_boleto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: ty_fator_cod_barras(4) TYPE n,
                 ty_fator_real(8) TYPE n.

    CLASS-DATA gv_data_base_1000 TYPE sy-datum READ-ONLY VALUE '20000703' ##NO_TEXT.
    CLASS-DATA gv_data_base_febraban TYPE sy-datum READ-ONLY VALUE '19971007' ##NO_TEXT.

    CLASS-METHODS fator_to_data
    IMPORTING iv_fator       TYPE string
    RETURNING VALUE(rv_date) TYPE d.

    CLASS-METHODS data_to_fator_cod_barras
    IMPORTING iv_data                    TYPE sy-datum
    RETURNING VALUE(rv_fator_cod_barras) TYPE ty_fator_cod_barras.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS calc_fator_real
    IMPORTING iv_fator_de_vencimento TYPE sy-datum
    RETURNING VALUE(rv_fator_real)   TYPE ty_fator_real.
ENDCLASS.



CLASS zoct_fator_vencimento_boleto IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZOCT_FATOR_VENCIMENTO_BOLETO=>CALC_FATOR_REAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FATOR_DE_VENCIMENTO         TYPE        SY-DATUM
* | [<-()] RV_FATOR_REAL                  TYPE        TY_FATOR_REAL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD calc_fator_real.
    DATA: lv_date_diff(8) TYPE n.

    lv_date_diff = iv_fator_de_vencimento - gv_data_base_febraban.
    rv_fator_real = lv_date_diff.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZOCT_FATOR_VENCIMENTO_BOLETO=>DATA_TO_FATOR_COD_BARRAS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_DATA                        TYPE        SY-DATUM
* | [<-()] RV_FATOR_COD_BARRAS            TYPE        TY_FATOR_COD_BARRAS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD data_to_fator_cod_barras.
    DATA:  lv_str_fator(8)     TYPE n.

    lv_str_fator = calc_fator_real( iv_data ).
    rv_fator_cod_barras = 999 + ( ( lv_str_fator - 999 ) MOD 9000 ).

    IF rv_fator_cod_barras = 999.
      rv_fator_cod_barras = 9999.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZOCT_FATOR_VENCIMENTO_BOLETO=>FATOR_TO_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FATOR                       TYPE        STRING
* | [<-()] RV_DATE                        TYPE        D
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD fator_to_data.
    DATA: lv_data_calc_ini       TYPE sy-datum,
          lv_data_calc_fim       TYPE sy-datum,
          lv_str_fator_hoje      TYPE i,
          lv_str_fator_vencido   TYPE i,
          lv_str_fator_avencer   TYPE i,
          lv_str_fator_transicao TYPE i,
          lv_calc_data           TYPE i,
          lv_dta_vencida         TYPE sy-datum,
          lv_dta_avencer         TYPE sy-datum,
          lv_dta_hoje            TYPE sy-datum.

    lv_dta_hoje = sy-datum.

    IF iv_fator > 0.
      lv_dta_vencida = lv_dta_hoje - 3000.
      lv_dta_avencer = lv_dta_hoje + 5500.
      lv_str_fator_hoje = calc_fator_real( lv_dta_hoje ).
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

      lv_calc_data = floor( ( lv_str_fator_hoje - 1000 ) / 9000 ).

      IF lv_calc_data <= 0.
        lv_calc_data = 1.
      ENDIF.

      lv_data_calc_ini = ( gv_data_base_1000 + ( 9000 * ( lv_calc_data - 1 ) ) ) + ( iv_fator  - 1000 ).
      lv_data_calc_fim = ( gv_data_base_1000 + (  9000 * ( lv_calc_data ) ) ) + (  iv_fator  - 1000 ).

      IF lv_dta_vencida <= lv_data_calc_ini AND lv_dta_avencer >= lv_data_calc_ini.
        rv_date = lv_data_calc_ini.
      ENDIF.

      IF lv_dta_vencida <= lv_data_calc_fim AND lv_dta_avencer >= lv_data_calc_fim.
        rv_date = lv_data_calc_fim.
      ENDIF.

      IF iv_fator  > lv_str_fator_vencido  AND iv_fator  < lv_str_fator_avencer.
        rv_date = ''.
      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.