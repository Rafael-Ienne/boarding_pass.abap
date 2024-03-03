*&---------------------------------------------------------------------*
*& Report Z_BOARDING_PASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_boarding_pass.

DATA: ld_rs           TYPE rs38l_fnam, "Variável que armazena o FM do Smartform dinamicamente
      wa_traveler     TYPE zst_traveler, "Estrutura com os dados que é passada como parametro para preencher Smartform
      date_difference TYPE i.

"Parâmetros para preenchimento do Smartform
SELECTION-SCREEN: BEGIN OF BLOCK b1.
PARAMETERS: p_name(30) TYPE c OBLIGATORY, "Nome do passageiro
            p_num      TYPE int1 OBLIGATORY, "Numero do voo
            p_depda    TYPE erdat OBLIGATORY, "Data de partida
            p_airpd(3) TYPE c OBLIGATORY MATCHCODE OBJECT ZAIRPORTS, "Aeroporto de partida com search help
            p_dept     TYPE spfli-deptime OBLIGATORY, "Horário de partida
            p_airpa(3) TYPE c OBLIGATORY MATCHCODE OBJECT ZAIRPORTS, "Aeroporto de chegada com search help
            p_arrt     TYPE spfli-arrtime OBLIGATORY, "Horario de chegada ao destino
            p_board    TYPE spfli-deptime OBLIGATORY, "Horario de embarque
            p_gate(50) TYPE c OBLIGATORY, "Portão
            p_seat     TYPE int1 OBLIGATORY, "Numero do assento
            p_class    TYPE c OBLIGATORY, "Classe do passageiro
            p_airl(3)  TYPE c OBLIGATORY. "Iniciais da airline
SELECTION-SCREEN: END OF BLOCK b1.

"Calcula a diferença entre a data de partida e a data atual
PERFORM f_difference_between_dates USING p_depda.

"Verifica se o campo de gate foi preenchido e, caso o passageiro nao saiba, coloca-se uma mensagem padrao
IF p_gate IS INITIAL.
  p_gate = 'Please check the departures board'.
ENDIF.

"Verifica se o horario do voo é menor que o de embarque e se a data de partida é menor que a atual
IF p_dept+0(2) - p_board+0(2) LT 0
   AND date_difference LT 0 .

  MESSAGE 'Give the information about boarding time and departure date correctly ' TYPE 'I' DISPLAY LIKE 'E'.

"Verifica apenas se a data de partida é menor que a atual
ELSEIF date_difference LT 0 .

  MESSAGE 'Give the information about departure date correctly ' TYPE 'I' DISPLAY LIKE 'E'.

"Verifica apenas se o horario do voo é menor que o de embarque
ELSEIF p_dept+0(2) - p_board+0(2) LT 0.

  MESSAGE 'Give the information about boarding time correctly ' TYPE 'I' DISPLAY LIKE 'E'.
ELSE.

  "Preenchimento da estrutura que será passado como parametro no smartform
  wa_traveler-id_name = p_name.
  wa_traveler-id_gate = p_gate.
  wa_traveler-id_flight_number = p_num.
  wa_traveler-id_departure_time = p_dept.
  wa_traveler-id_departure_date = p_depda.
  wa_traveler-id_departure_airport = p_airpd.
  wa_traveler-id_class = p_class.
  wa_traveler-id_boarding_time = p_board.
  wa_traveler-id_arrival_time = p_arrt.
  wa_traveler-id_arrival_airport = p_airpa.
  wa_traveler-id_seat = p_seat.
  wa_traveler-id_airline_initials = p_airl.

  "Verificação da airline escolhidA e passagem de seu respectivo site para gerar QR code
  CASE p_airl.
    WHEN 'AA'.
      wa_traveler-id_airline_link = 'https://www.aa.com.br/homePage.do?locale=pt_BR'.
    WHEN 'AB'.
      wa_traveler-id_airline_link = 'https://www.airberlin.com/'.
    WHEN 'AC'.
      wa_traveler-id_airline_link = 'http://www.aircanada.com.br/beta/'.
    WHEN 'AF'.
      wa_traveler-id_airline_link = 'https://wwws.airfrance.com.br/'.
    WHEN 'AZ'.
      wa_traveler-id_airline_link = 'https://www.ita-airways.com/pt_br'.
    WHEN 'BA'.
      wa_traveler-id_airline_link = 'https://www.britishairways.com/travel/home/public/pt_br/'.
    WHEN 'CO'.
      wa_traveler-id_airline_link = 'https://www.united.com/pt/br'.
    WHEN 'DL'.
      wa_traveler-id_airline_link = 'https://www.delta.com'.
    WHEN 'FJ'.
      wa_traveler-id_airline_link = 'https://www.fijiairways.com/en-us/'.
    WHEN 'JL'.
      wa_traveler-id_airline_link = 'https://www.jal.co.jp/br/pt/'.
    WHEN 'LH'.
      wa_traveler-id_airline_link = 'https://www.lufthansa.com/br/pt/homepage'.
    WHEN 'NG'.
      wa_traveler-id_airline_link = 'https://www.laudaeurope.com/'.
    WHEN 'NW'.
      wa_traveler-id_airline_link = 'https://northwestairlineshistory.org/aircraft/'.
    WHEN 'QF'.
      wa_traveler-id_airline_link = 'https://www.qantas.com/br/en.html'.
    WHEN 'SA'.
      wa_traveler-id_airline_link = 'https://www.flysaa.com/'.
    WHEN 'SQ'.
      wa_traveler-id_airline_link = 'https://www.singaporeair.com/pt_BR/br/home#/book/bookflight'.
    WHEN 'SR'.
      wa_traveler-id_airline_link = 'https://www.swiss.com/br/pt/homepage'.
    WHEN 'UA'.
      wa_traveler-id_airline_link = 'https://www.united.com/pt/br'.
    WHEN OTHERS.
      MESSAGE 'Give the information about airline correctly ' TYPE 'I' DISPLAY LIKE 'E'.

  ENDCASE.

  "Preenchimento da variavel que rmazena o nome da FM do smartform dinamicamente
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname = 'Z_SMARTFORM_BOARDING_PASS'
    IMPORTING
      fm_name  = ld_rs.

  IF sy-subrc IS INITIAL.
    "Chamada do FM do smartform e passagem dos parametros para seu preenchimento
    CALL FUNCTION ld_rs
      EXPORTING
        wa_traveler = wa_traveler.
  ENDIF.

ENDIF.

FORM f_difference_between_dates USING p_departure_date.

  CLEAR: date_difference.

  date_difference = ( p_departure_date+0(4) * 365 + p_departure_date+4(2) * 30 + p_departure_date+6(2) ) -
                   ( sy-datum+0(4) * 365 + sy-datum+4(2) * 30 + sy-datum+6(2) ).

ENDFORM.