; *****************************************************************
; * FILENAME:   creg.s                                            *
; * AUTHOR:     meier@msoe.edu <Dr. M.>                           *
; * PROVIDES:   number equates for each MC68HC11 control register *
; * DATE:       7 Dec 2005                                        *
; * PROJECT:    OS11                                              *
; *****************************************************************

PORTA               equ       $1000
PIOC                equ       $1002
PORTCL              equ       $1005
DDRC                equ       $1007
PORTD               equ       $1008
DDRD                equ       $1009
PORTE               equ       $100A
CFORC               equ       $100B
OC1M                equ       $100C
OC1D                equ       $100D
TCNTH               equ       $100E
TCNTL               equ       $100F
TIC1H               equ       $1010
TIC1L               equ       $1011
TIC2H               equ       $1012
TIC2L               equ       $1013
TIC3H               equ       $1014
TIC3L               equ       $1015
TOC1H               equ       $1016
TOC1L               equ       $1017
TOC2H               equ       $1018
TOC2L               equ       $1019
TOC3H               equ       $101A
TOC3L               equ       $101B
TOC4H               equ       $101C
TOC4L               equ       $101D
TI4O5H              equ       $101E
TI4O5L              equ       $101F
TCTL1               equ       $1020
TCTL2               equ       $1021
TMSK1               equ       $1022
TFLG1               equ       $1023
TMSK2               equ       $1024
TFLG2               equ       $1025
PACTL               equ       $1026
PACNT               equ       $1027
SPCR                equ       $1028
SPSR                equ       $1029
SPDR                equ       $102A
BAUD                equ       $102B
SCCR1               equ       $102C
SCCR2               equ       $102D
SCSR                equ       $102E
SCDR                equ       $102F
ADCTL               equ       $1030
ADR1                equ       $1031
ADR2                equ       $1032
ADR3                equ       $1033
ADR4                equ       $1034
BPROT               equ       $1035
EPROG               equ       $1036
OPTION              equ       $1039
COPRST              equ       $103A
PPROG               equ       $103B
HPRIO               equ       $103C
INIT                equ       $103D
CONFIG              equ       $103F

; FOX11 BOARD OPERATES IN EXPANDED MODE
;   - MC68HC11 PORTB AND PORTC PINS UNAVAILABLE IN EXPANDED MODE
;   - FOX11 BOARD PROVIDES REPLACEMENTS FOR PORTC AND PORTB
;   - FOX11 BOARD ADDS A MEMORY-MAPPED PORTF FOR LCD CONTROL

PORTF               equ       $1401               ; LCD CONTROL
PORTC               equ       $1403               ; DIP SWITCH INPUT
PORTB               equ       $7000               ; LED OUTPUT
