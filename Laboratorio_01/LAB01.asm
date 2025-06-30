;My first section
include P18F4550.inc
;Second section - Doesn't have be settings to guide one
;CONFIG FOSC=INTOSC_EC
aux1 equ 0h
aux2 equ 1h
aux3 equ 2h
aux4 equ 3h 

Inicio 
 ;Punto 1
 movlw .7
 movwf aux1
 addlw .3
 movwf aux4
 
 ;Punto 2
 movlw .8
 movwf aux1
 movlw .10
 movwf aux2
 movf aux1, w
 addwf aux2, w
 movwf aux4
 
 ;Punto 3
 movlw .5 ;5<-w
 movwf aux1 ;w<-aux1
 sublw .9 ;9<-w
 
 ;Punto 4
 movlw .6
 movwf aux1
 movlw .4
 movwf aux2
 movf aux1, w
 subwf aux2, w
 movwf aux4
 
 ;Punto 5
 movlw .5;
 movwf aux1;
 
 movlw .4; w <- 4 
 mulwf aux1 
 
 movf PRODL, W 
 movwf aux1 

 ;Punto 6
 movlw .12
 movwf aux1
 movlw .15
 movwf aux2 ;Es algo de requisito del punto
 mulwf aux1
 movf PRODL, w
 movwf aux4
 
    ;Punto 7
 movlw .12 ;12<-w
 movwf aux1 ;w<-aux1
 comf aux1, 1

 ;Punto 8
 movlw .12
 movwf aux1
 negf aux1
 movf aux1, w
 movwf aux4
 
 ;Punto 9
 movlw .35; W <- 35
 movwf aux1; aux1 <- 35
 
 movlw .7; W <- 7
 iorwf aux1, W; W <- W OR aux1, hacemos OR bit a bit y lo guardamos en W.
 
 ;Punto 10
 movlw .20
 movwf aux1
 movlw .56
 movwf aux2 ;Esto es omitible 
 iorwf aux1, w
 movwf aux4
 
 ;Punto 11
 movlw .62  ;62<-w
 movwf aux1 ;w<-aux1
 andlw .15
 
 ;Punto 12
  movlw .100
  movwf aux1
  movlw .45
  movwf aux2    ;00101101
  andwf aux1, w ;01100100
  movwf aux4 ;00100100
 
 ;Punto 13
 movlw .120; W <- 120
 movwf aux1; aux1 <- 120
 
 movlw .1; W <- 1
 xorwf aux1, W; W <- W XOR aux1
 
 ;Punto 14
 movlw .17
 movwf aux1
 movlw .90
 movwf aux2
 xorwf aux1, w
 movwf aux4
 
 ;Punto 15
 
 ;aux4 <-(aux1 OR aux2) AND (aux3 XOR 0xD0)
 movlw .25  ;25<-w
 movwf aux1 ;w<-aux1
 movlw .40 ;40<-w
 movwf aux2 ;w<-aux2
 movlw .103 ;103<-w
 movwf aux3 ;w<-aux3
 movlw .208 ;208<-w
 xorwf aux3, 1
 movf aux1,w ;aux1<-w
 iorwf aux2, 0
 andwf aux3, 0
 movwf aux4

 ;Punto 16
 movlw .18
 movwf aux1
 movlw .60
 movwf aux2
 movlw .16
 movwf aux3    
    ;aux1+aux2
 movf aux1, w
 addwf aux2, w
 movwf aux4   ;78    
    ;-3*(aux3-0b11010)--(26)
; aux3 - 26
 movf aux3, w        ; W = 16
 sublw .26           ; W = 26 - 16 = 10
 mullw .3            ; 3 * 10 = 30
 movf PRODL, w       ; W = 30

; Suma final
 addwf aux4, w       ; 78 + 30 = 108
 movwf aux4
 
    goto Inicio	
 
end


