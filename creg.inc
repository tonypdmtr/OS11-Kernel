;*******************************************************************************
; FILENAME:   creg.s
; AUTHOR:     meier@msoe.edu <Dr. M.>
; PROVIDES:   number equates for each MC68HC11 control register
; DATE:       7 Dec 2005
; PROJECT:    OS11
;*******************************************************************************

REGS                def       $1000
PORTA               equ       REGS+$00
PIOC                equ       REGS+$02
PORTCL              equ       REGS+$05
DDRC                equ       REGS+$07
PORTD               equ       REGS+$08
DDRD                equ       REGS+$09
PORTE               equ       REGS+$0A
CFORC               equ       REGS+$0B
OC1M                equ       REGS+$0C
OC1D                equ       REGS+$0D
TCNTH               equ       REGS+$0E
TCNTL               equ       REGS+$0F
TIC1H               equ       REGS+$10
TIC1L               equ       REGS+$11
TIC2H               equ       REGS+$12
TIC2L               equ       REGS+$13
TIC3H               equ       REGS+$14
TIC3L               equ       REGS+$15
TOC1H               equ       REGS+$16
TOC1L               equ       REGS+$17
TOC2H               equ       REGS+$18
TOC2L               equ       REGS+$19
TOC3H               equ       REGS+$1A
TOC3L               equ       REGS+$1B
TOC4H               equ       REGS+$1C
TOC4L               equ       REGS+$1D
TI4O5H              equ       REGS+$1E
TI4O5L              equ       REGS+$1F
TCTL1               equ       REGS+$20
TCTL2               equ       REGS+$21
TMSK1               equ       REGS+$22
TFLG1               equ       REGS+$23
TMSK2               equ       REGS+$24
TFLG2               equ       REGS+$25
PACTL               equ       REGS+$26
PACNT               equ       REGS+$27
SPCR                equ       REGS+$28
SPSR                equ       REGS+$29
SPDR                equ       REGS+$2A
BAUD                equ       REGS+$2B
SCCR1               equ       REGS+$2C
SCCR2               equ       REGS+$2D
SCSR                equ       REGS+$2E
SCDR                equ       REGS+$2F
ADCTL               equ       REGS+$30
ADR1                equ       REGS+$31
ADR2                equ       REGS+$32
ADR3                equ       REGS+$33
ADR4                equ       REGS+$34
BPROT               equ       REGS+$35
EPROG               equ       REGS+$36
OPTION              equ       REGS+$39
COPRST              equ       REGS+$3A
PPROG               equ       REGS+$3B
HPRIO               equ       REGS+$3C
INIT                equ       REGS+$3D
CONFIG              equ       REGS+$3F

;*******************************************************************************
; FOX11 BOARD OPERATES IN EXPANDED MODE
;   - MC68HC11 PORTB AND PORTC PINS UNAVAILABLE IN EXPANDED MODE
;   - FOX11 BOARD PROVIDES REPLACEMENTS FOR PORTC AND PORTB
;   - FOX11 BOARD ADDS A MEMORY-MAPPED PORTF FOR LCD CONTROL
;*******************************************************************************

PORTF               equ       $1401               ; LCD CONTROL
PORTC               equ       $1403               ; DIP SWITCH INPUT
PORTB               equ       $7000               ; LED OUTPUT
