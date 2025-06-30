;=====================================
;  LAB 3 con PIC18F4550
;  Pines usados RA1 RE0?RE2 RB0?RB1 RC1 PORTD
;  Funciones RGB LED 1Hz display interrupción emergencia
    
;=====================================
;Header
include P18F4550.inc
;==============================
    
;==============================
;  CONFIGURACIÓN DE BUSES
;==============================
CONFIG FOSC = HS        ; Oscilador externo (4 MHz)
CONFIG WDT = OFF        ; Watchdog Timer OFF
CONFIG LVP = OFF        ; Low Voltage Programming OFF
;CONFIG PBADEN = OFF     ; RB0-RB4 como digitales

;==============================
;  VARIABLES EN RAM
;==============================
counter         equ 0h
rgb_state       equ 1h
first_press     equ 2h
     
;==============================
;  VECTORES DE RESET E INTERRUPCIONES
;==============================
;Reset Vector
ORG 0h
    goto MAIN
;High Priority Interruption Vector
ORG 8h
    goto ISR
;Low Priority Interruption Vector
ORG 18h
    goto ISRL
    
;==============================
;Main SetUp
MAIN;
    ;Setting Puertos
    movlw 0x0E
    movwf ADCON1            ; 

    movlw b'11110000'
    movwf TRISD             ; RD0-RD3 como Salida
    clrf TRISE              ; RGB como salida (Puerto E, excepto main clear)
    bcf TRISA, 1            ; RA1 salida (LED)

    movlw b'00000011'       ; RB0 (INT0) y RB1 (Reset) entradas
    movwf TRISB
    bsf TRISC, 1            ; RC1 entrada (Incremento)

    ;Outputs Logic 
    clrf LATD		    ; 7Segmentos en 0
    setf LATE               ; LED RGB apagado (Negro)
    clrf LATA               ; LED 1Hz apagado
    clrf counter
    clrf rgb_state
    clrf first_press        ; Marca que aún no se ha presionado

    ;Interruption Setting
    bsf RCON,IPEN           ;Activa Interrupciones con prioridad

     ;High Priority
      ;INT0
    bcf INTCON, INT0IF      ;Limpia la bandera de la interrupción INT0
    bsf INTCON, INT0IE      ;Habilita la interrupción INT0  
    bsf INTCON2, INTEDG0    ;Flanco Acendente INT0

     ;Low Priority
      ;TRM0
       ;Precarga = 2^N - (Tsobreflujo * Fbus /PS);
	;Precarga = 2^16 - 1e6/16 = 3036; N=16, PS=16, Fbus=1MHz  ,Fcristal = 4MHz, Tsobrelujo = 1sec.
	;Sin Precarga: Tsobrelujo = 16*^2^16/1e6=1.04857s
    ;movlw b'00000011'	    ; configuración para que funcione como un temporizador y que tenga un preescaler de 16(FBus va a ser de 1MHz con el crista) 
    bcf INTCON, TMR0IF      ;Limpia la bandera de la interrupción TMR0
    bsf INTCON, TMR0IE      ;Habilita la interrupción TMR0
    bcf INTCON2, TMR0IP     ;Low Priority TMR0

      ;INT1
    bcf INTCON3, INT1IF     ;Limpia la bandera de la interrupción INT1
    bsf INTCON3, INT1IE     ;Habilita la interrupción INT1
    bcf INTCON3, INT1IP     ;Low Priority INT1
    bsf INTCON2, INTEDG1    ;Flanco Acendente INT1

      ;INT2
    bcf INTCON3, INT2IF     ;Limpia la bandera de la interrupción INT2
    bsf INTCON3, INT2IE     ;Habilita la interrupción INT2
    bcf INTCON3, INT2IP     ;Low Priority INT2
    bsf INTCON2, INTEDG2    ;Flanco Acendente INT2

     ;GLOBAL
    bsf INTCON, GIEH        ;Habilita Interrupciones HP
    bsf INTCON, GIEL        ;Habilita Interrupciones LP

    ;TMR0 Initialization
    movlw b'00000011'
    movwf T0CON
    movlw b'00001011'
    movwf TMR0H            ;carga el valor alto del temporizador
    movlw b'11011100'
    movwf TMR0L            ;carga el valor bajo del temporizador (3036)
    bsf T0CON,TMR0ON       ;enciende el temporizador

;==============================
;Main Loop
LOOP;
    btfss PORTC, 1
    goto LOOP

INC_COUNTER
    call WAIT_RELEASE_RC1
    movf first_press, W  ; Verificar si es la primera vez
    bz FIRST_COLOR
    goto NORMAL_INC

FIRST_COLOR
    ;incf rgb_state, f
    incf first_press, f
    call SET_RGB_COLOR
    movwf LATE
    incf counter, f
    goto UPDATE_DISPLAY

NORMAL_INC
    incf counter, f
    movf counter, W
    sublw .10
    btfss STATUS, Z
    goto UPDATE_DISPLAY
    clrf counter
    incf rgb_state, f
    incf rgb_state, f	;incrementar 2 veces. Puesto que PCL necesita multiplos de 2, así que la cuenta estará también en X2
    movf rgb_state, W
    sublw .12
    btfss STATUS, Z
    goto SET_RGB
    clrf rgb_state
SET_RGB
    call SET_RGB_COLOR
    movwf LATE
UPDATE_DISPLAY
    movf counter, W
    movwf LATD
    goto LOOP

;==============================
;Subrutinas
WAIT_RELEASE_RC1
    btfsc PORTC, 1
    goto WAIT_RELEASE_RC1
    return

SET_RGB_COLOR       ;Red: RE2  , Green: RE1  ,  Blue: RE0
    movf rgb_state, W
    addwf PCL, f
    retlw b'010' ; 0 - Magenta
    retlw b'011' ; 2 - Azul
    retlw b'001' ; 4 - Cyan
    retlw b'101' ; 6 - Verde
    retlw b'100' ; 8 - Amarillo
    retlw b'000' ; 10 - Blanco

;==============================
;Interrupciones
ISR
    btfss INTCON, INT0IF
    retfie
    bcf INTCON, INT0IF
    movlw b'00000110'        ;Rojo encendido
    movwf LATE
    clrf LATA                ;Led 1 Hz apagado
EMERGENCY_LOOP
    goto EMERGENCY_LOOP

ISRL
    btfsc INTCON3, INT1IF
    call ISRLReset
    btfsc INTCON, TMR0IF
    call ISRLTimer
    retfie
ISRLReset
    bcf INTCON3, INT1IF
    clrf counter
    clrf LATD
    clrf rgb_state
    call SET_RGB_COLOR
    movwf LATE
    ;clrf first_press
    retfie

ISRLTimer
    bcf INTCON, TMR0IF
    movlw b'00001011'
    movwf TMR0H
    movlw b'11011100'
    movwf TMR0L
    comf LATA
   retfie
end