;*******************************************************************************
; OS11 Kernel
;
; Original kernal written by Andrew Mischock and Jonathan Dunder
;       for CS384 - Operating Systems [2006.02.14]
;
; Modifications made by Andrew Mischock
;       for CS391 - Embedded System Design [2006.03.26]
;
; Major refactoring and optimizations by Tony Papadimitriou [-480 bytes]
;       for fun - [2020.12.06]
;*******************************************************************************

                    #CaseOn
                    #ExtraOn
                    #Uses     creg.inc
                    #Uses     mem.inc

BUS_KHZ             def       2000

CR                  equ       0x0D
LF                  equ       0x0A

LCD_COLS            equ       16
LCD_DATA            equ       PORTF

PROCESSES           equ       8

                    #temp     0xD8FF
P7_STACK            next      :temp,256
P6_STACK            next      :temp,256
P5_STACK            next      :temp,256
P4_STACK            next      :temp,256
P3_STACK            next      :temp,256
P2_STACK            next      :temp,256
P1_STACK            next      :temp,256
P0_STACK            next      :temp,256

Vrti                equ       0x00EB

;*******************************************************************************
; Macros
;*******************************************************************************

?motor              macro
          #ifdef MOTOR
                    lda       ~1~
                    sta       MOTOR
          #endif
                    endm

;*******************************************************************************
                    #RAM
;*******************************************************************************
                    org       DATA

proc_table          rmb       6*PROCESSES
buffer              rmb       20
buf_index           rmb       1
kvar                rmb       1
proc_number         rmb       1
svar                rmb       1
pslcd2              rmb       LCD_COLS
sndtmp              rmb       1

;*******************************************************************************
                    #VECTORS                      ;Bootstrap
;*******************************************************************************

                    org       Vrti
                    jmp       RTI_Handler

;*******************************************************************************
                    #ROM
;*******************************************************************************
                    org       CODE

Start               proc
                    lds       #STACK              ;OS Boot sequence
                    sei
                    lda       PACTL
                    ora       #%00001001          ;Set PA3 to O, 8MHz XTAL (8.192ms)
                    sta       PACTL
                    lda       TMSK2
                    ora       #%01000000
                    sta       TMSK2
;                   clr       DDRC                ;PC1 used for reset button on Fox11
                    lda       #'0'
                    sta       BAUD
                    lda       #0x0C
                    sta       SCCR2
                    clra
          ;--------------------------------------
?                   macro
                    #temp     ~1~*6
                    lds       #P~1~_STACK
                    ldx       #P~1~
                    pshx
                    ldb       #7
Loop$$$             psha
                    decb
                    bne       Loop$$$
                    ldx       #proc_table
                    tsy
                    sty       :temp,x
                    clr       :temp+2,x           ;sleep state (1 is sleeping)
                    clr       :temp+3,x           ;CPU time
                    clr       :temp+4,x           ;aging
                    clr       :temp+5,x           ;priority is on the end
                    endm
          ;--------------------------------------
                    @?        0
                    @?        1
                    @?        2
                    @?        3
                    @?        4
                    @?        5
                    @?        6
                    @?        7
          ;-------------------------------------- ;Initialize variables
                    sta       kvar
                    sta       svar
                    ldx       #REGS
                    bset      [OPTION,x,%10000000
                    lda       #%00000111
                    sta       [ADCTL,x
                    sta       DDRC
                    sta       buf_index
                    lda       #PROCESSES-1
                    sta       proc_number
          ;--------------------------------------
                    jsr       InitLCD             ;Initialize the LCD
                    ldx       #WLCM               ;Intro Message to LCD
                    jsr       LCD_PutChar
                    bsr       WelcomeSound
                    cli                           ;Enable interrupts
                    jmp       P7                  ;Start with P7

;*******************************************************************************
; Interrupt Service Routine
;*******************************************************************************

RTI_Handler         proc
                    ldx       #proc_table         ;Increment process' CPU time
                    ldb       proc_number
                    lda       #6
                    mul
                    abx
                    inc       3,x
                    tsy                           ;Store state of process
                    sty       ,x
Loop@@              ldb       proc_number
                    bne       _1@@                ;Make sure process number doesn't go below 0
                    ldb       #PROCESSES
_1@@                decb
                    stb       proc_number
          ;--------------------------------------
                    lda       #6
                    mul
                    ldx       #proc_table
                    abx
                    lda       2,x
                    cmpa      #1                  ;Check if sleeping
                    beq       Loop@@
          ;--------------------------------------
                    lda       4,x
                    brclr     4,x,%11111111,_2@@
                    deca
                    sta       4,x
                    bra       Loop@@
_2@@                lda       5,x
                    sta       4,x
                    ldx       ,x                  ;If not sleeping, run process
                    txs
                    lda       svar
                    coma
                    bne       Done@@
          ;-------------------------------------- ;endless loop [HALT]
Halt@@              sei
                    bra       Halt@@
          ;--------------------------------------
Done@@              lda       #%01000000
                    sta       TFLG2
                    rti

;*******************************************************************************

WelcomeSound        proc
                    ldd       #$1E1E
                    bsr       PlaySound
                    ldd       #$231C
                    bsr       PlaySound
                    ldd       #$281A
                    bsr       PlaySound
                    ldd       #$2D18
                    bsr       PlaySound
                    ldd       #$3216
;                   bra       PlaySound

;*******************************************************************************

PlaySound           proc
                    sta       sndtmp
Loop@@              lda       PORTA
                    ora       #%00001000
                    sta       PORTA
                    lda       sndtmp
Up@@                jsr       Wait20th_ms
                    deca
                    bne       Up@@
                    lda       PORTA
                    anda      #%11110111
                    sta       PORTA
                    lda       sndtmp
Down@@              jsr       Wait20th_ms
                    deca
                    bne       Down@@
                    decb
                    bne       Loop@@
                    rts

;*******************************************************************************

GetChar             proc
                    pshx
                    ldx       #REGS
                    brclr     [SCSR,x,%00100000,*
                    lda       [SCDR,x
                    pulx
                    rts

;*******************************************************************************
; P7: Serial Port Shell

MainLoop            proc
                    clr       buf_index           ;Clear input buffer and return
Loop@@              bsr       GetChar
                   ;@?motor   #0xF7
          ;--------------------------------------
                    ldx       #buffer
                    ldb       buf_index
                    abx
                    sta       ,x
                    inc       buf_index
          ;--------------------------------------
                    cmpa      #CR
                    beq       _2@@
                    jsr       PutChar
                    bra       Loop@@
          ;--------------------------------------
_2@@                lda       #LF
                    jsr       PutChar
                    lda       #'>'
                    jsr       PutChar
;                   bra       CheckInputBuffer

;*******************************************************************************
P7                  equ       Loop@@
;*******************************************************************************

CheckInputBuffer    proc
                    ldb       buf_index
                    cmpb      #3
                    beq       Go@@
          #ifdef
                    cmpb      #5
                    beq       ADCF
                    cmpb      #7
                    beq       REBOOT
                    cmpb      #9
                    beq       SHDOWNJ
                    cmpb      #10
                    beq       MD
                    cmpb      #15
                    beq       MM
          #endif
                    bra       MainLoop

Go@@                lda       buffer
                    cmpa      #'p'
                    beq       PS
                    cmpa      #'s'
                    beq       SX
                    cmpa      #'r'
                    bne       MainLoop
;                   bra       RX

;*******************************************************************************
; Run PX

RX                  proc
                    bsr       ?Offset
                    bra       MainLoop

;*******************************************************************************
; Sleep PX

SX                  proc
                    bsr       ?Offset
                    inc       2,x
                    bra       MainLoop

;*******************************************************************************

?Offset             proc
                    ldx       #buffer
                    ldb       1,x
                    subb      #'0'
                    ldx       #proc_table
                    lda       #6
                    mul
                    abx
                    clr       2,x
                    rts

;*******************************************************************************

Print               proc
                    pshx
Loop@@              lda       ,x
                    beq       Done@@
                    bsr       PutChar
                    inx
                    bra       Loop@@
Done@@              pulx
                    rts

;*******************************************************************************
; Display PS

PS                  proc
                    ldx       #PSDAT
                    bsr       Print
                    ldx       #proc_table
                    clrb
                    ldy       #pslcd2
Loop@@              bsr       PrintSpace2
                    tba                           ;PID
                    jsr       ConvertAndSend
                    bsr       PrintSpace2
                    lda       2,x                 ;STATE
                    adda      #'R'                ;add 0x52 so: 0=>R & 1=>S
                    sta       ,y                  ;store in pslcd2
                    lda       2,x                 ;reload STATE
                    bsr       ConvertAndSend
                    bsr:2     PrintSpace2
                    lda       3,x                 ;CPUTIME
                    bsr       ConvertAndSend
                    bsr:2     PrintSpace2
                    bsr       PrintSpace
                    lda       4,x                 ;AGE
                    bsr       ConvertAndSend
                    bsr       PrintSpace2
                    bsr       PrintSpace
                    lda       5,x                 ;PRIORITY
                    bsr       ConvertAndSend
                    lda       #LF
                    bsr       PutChar
                    incb
                    cmpb      #8
                    beq       _3@@
                    inx:6
                    iny
                    bra       Loop@@

;*******************************************************************************

PrintSpace2         proc
                    bsr       PrintSpace
;                   bra       PrintSpace
                    endp

;*******************************************************************************

PrintSpace          proc
                    lda       #' '
;                   bra       PutChar
                    endp

;*******************************************************************************

PutChar             proc
                    pshx
                    ldx       #REGS
                    brclr     [SCSR,x,%10000000,*
                    sta       [SCDR,x
                    brset     ,x,%01000000,*
                    pulx
                    rts
                    endp

;*******************************************************************************

_3@@                lda       kvar
                    cmpa      #0xF0
                    bne       _4@@
                    lda       #0xFF
                    sta       svar
                    bra       MainLoop@@
_4@@                jsr       ClearLCD
                    ldx       #PSLCD1             ;PS to LCD
                    jsr       LCD_PutChar
                    jsr       LCD_Line2
                    ldx       #pslcd2
                    lda       #' '
                    sta       8,x
                    sta       9,x
                    sta       10,x
                    sta       11,x
                    sta       12,x
                    sta       13,x
                    lda       #'P'
                    sta       14,x
                    lda       #'S'
                    sta       15,x
                    jsr       LCD_PutChar
MainLoop@@          jmp       MainLoop

;*******************************************************************************
; Convert Binary to ASCII and send

ConvertAndSend      proc
                    psha
                    lsra:4
                    bsr       BinToASCII
                    bsr       PutChar
                    pula
                    bsr       BinToASCII
                    bra       PutChar

;*******************************************************************************

BinToASCII          proc
                    anda      #%00001111
                    cmpa      #9
                    bls       Digit@@
                    adda      #'a'-10-'0'
Digit@@             adda      #'0'
                    rts

;*******************************************************************************
; P6

P6                  proc
Loop@@              @?motor   #0xF6               ;Dummy
                    bra       Loop@@

P5                  proc
Loop@@              @?motor   #0xF5               ;Dummy
                    bra       Loop@@

P4                  proc
Loop@@              @?motor   #0xF4               ;Dummy
                    bra       Loop@@

P3                  proc
Loop@@              @?motor   #0xF3               ;Dummy
                    bra       Loop@@

P2                  proc
Loop@@              @?motor   #0xF2               ;Dummy
                    bra       Loop@@

P1                  proc
Loop@@              @?motor   #0xF1               ;Dummy
                    bra       Loop@@

P0                  proc
Loop@@              @?motor   #0xF0               ;Dummy
                    bra       Loop@@

;*******************************************************************************
; Wait Routines

Wait15ms            proc
                    pshd
                    tpa
                    ldb       #15
Loop@@              bsr       Wait1ms
                    decb
                    bne       Loop@@
                    tap
                    puld
                    rts

;*******************************************************************************

Wait1ms             proc
                    pshd
                    tpa
                    lda       #20
Loop@@              bsr       Wait20th_ms
                    decb
                    bne       Loop@@
                    tap
                    puld
                    rts

;*******************************************************************************
                              #Cycles
Wait20th_ms         proc
                    pshd
                    tpa
                    ldb       #DELAY@@
                              #Cycles
Loop@@              decb
                    bne       Loop@@
                              #temp :cycles
                    tap
                    puld
                    rts

DELAY@@             equ       BUS_KHZ/20-:cycles-:ocycles/:temp
#ifdef LCD
;*******************************************************************************

InitLCD             proc
                    bsr       Wait15ms
          ;-------------------------------------- ;Send initialization sequence
                    ldx       #Table@@
Loop@@              lda       ,x                  ;A = value
                    bsr       WriteLCD
                    inx
                    lda       ,x                  ;A = extra delay in msec
                    beq       Cont@@
Delay@@             bsr       Wait1ms
                    deca
                    bne       Delay@@
Cont@@              inx
                    cpx       #Table@@+::Table@@
                    blo       Loop@@
                    bra       ClearLCD
;-------------------------------------------------------------------------------
Table@@             fcb       %00110010,6
                    fcb       %00110010,1
                    fcb       %00110010,1
                    fcb       %00100010,1
                    fcb       %00100010,0         ;Now in 4-bit mode
                    fcb       %10000010,0
                    fcb       %00000010,0         ;Display Off
                    fcb       %10000010,0
                    fcb       %00000010,0         ;Return home
                    fcb       %00100010,0
                    fcb       %00000010,0         ;Entry mode set
                    fcb       %01100010,0
                    fcb       %00000010,0         ;turn display on
                    fcb       %11110010,0
                    #size     Table@@

;*******************************************************************************

ClearLCD            proc
                    lda       #%00000010          ;Clear display
                    bsr       WriteLCD
                    lda       #%00010010
;                   bra       WriteLCD

;*******************************************************************************

WriteLCD            proc
                    sta       LCD_DATA            ;Write value in A to LCD
                    bsr       Wait1ms
                    psha
                    anda      #%11111101
                    sta       LCD_DATA
                    pula
                    bra       Wait1ms

;*******************************************************************************

LCD_Line2           proc
                    lda       #%11000010          ;Jump to line 2
                    bsr       WriteLCD
                    lda       #%00010010          ;Shift left
                    bsr:2     WriteLCD
                    lda       #%00000010
                    bra       WriteLCD

;*******************************************************************************

LCD_PutChar         proc
                    ldb       #LCD_COLS
Loop@@              beq       Done@@
                    lda       ,x
                    beq       Done@@
                    bsr       Send@@
                    lda       ,x
                    lsla:4
                    bsr       Send@@
                    inx
                    decb
                    bra       Loop@@
          ;--------------------------------------
Send@@              anda      #%11110000
                    ora       #%00000011
                    bra       WriteLCD
          ;--------------------------------------
Done@@              equ       :AnRTS
#endif
;*******************************************************************************

PSDAT               fcs       'PID STATE CPUTIME AGE PRIORITY',LF
WLCM                fcs       'WELCOME TO OS11'
PSLCD1              fcs       '01234567    OS11'
;                   fcb       'SHUTTING DOWN'
;                   fcb       'PE =    mV  OS11'
;                   fcb       '             ADC'

;*******************************************************************************
#ifndef LCD
                    rts
InitLCD             def       :AnRTS
LCD_Line2           def       :AnRTS
ClearLCD            def       :AnRTS
WriteLCD            def       :AnRTS
LCD_PutChar         def       :AnRTS
#endif
;*******************************************************************************
