;*******************************************************************************
; OS11 Kernel
;
; Original kernal written by Andrew Mischock and Jonathan Dunder
;       for CS384 - Operating Systems [2.14.2006]
;
; Modifications made by Andrew Mischock
;       for CS391 - Embedded System Design [3.26.2006]
;*******************************************************************************

                    #Uses     creg.inc
                    #Uses     mem.inc

P7stack             equ       0xD8FF
P6stack             equ       0xD9FF
P5stack             equ       0xDAFF
P4stack             equ       0xDBFF
P3stack             equ       0xDCFF
P2stack             equ       0xDDFF
P1stack             equ       0xDEFF
P0stack             equ       0xDFFF
RTIVEC              equ       0x00EB

                    org       DATA
PROCTBL             rmb       48
SLEEPD1             rmb       1
SLEEPD2             rmb       1
BUFFER              rmb       20
BUFFPTR             rmb       1
CONVR               rmb       1
DEB                 rmb       1
KVAR                rmb       1
PROCNUM             rmb       1
PSDAT               fcb       "PID STATE CPUTIME AGE PRIORITY",0x0A
WLCM                fcb       "WELCOME TO OS11",0x0A
PSLCD1              fcb       "01234567    OS11"
SHUTDOW             fcb       "SHUTTING DOWN"
ADCT1               fcb       "PE =    mV  OS11"
ADCT2               fcb       "             ADC"
SVAR                rmb       1
PSLCD2              rmb       16
SNDTMP              rmb       1
DTEMP               rmb       2
DTEMP2              rmb       2
ONES                rmb       1
TENS                rmb       1
HDRDS               rmb       1
THSDS               rmb       1

; **********
; Bootstrap
; **********

                    org       RTIVEC
                    jmp       ISR

                    org       CODE

BOOT                lds       #STACK              ; OS Boot sequence
                    sei
                    ldaa      PACTL
                    oraa      #%00001001          ; Set PA3 to O, 8MHz XTAL (8.192ms)
                    staa      PACTL
                    ldaa      TMSK2
                    oraa      #%01000000
                    staa      TMSK2
;                   ldaa      #0
;                   staa      DDRC                ; PC1 used for reset button on Fox11
                    ldaa      #0x30
                    staa      BAUD
                    ldaa      #0x0C
                    staa      SCCR2

INITP0              lds       #P0stack
                    ldx       #P0
                    pshx
                    clra
                    psha:7
                    ldy       #PROCTBL
                    tsx
                    stx       0,Y
                    ldaa      #0
                    staa      2,Y                 ; sleep state (1 is sleeping)
                    staa      3,Y                 ; CPU time
                    ldaa      #0
                    staa      4,Y                 ; aging
                    staa      5,Y                 ; priority is on the end

INITP1              lds       #P1stack
                    ldx       #P1
                    pshx
                    clra
                    psha:7
                    ldy       #PROCTBL
                    tsx
                    stx       6,Y
                    ldaa      #0
                    staa      8,Y
                    staa      9,Y
                    ldaa      #0
                    staa      10,Y
                    staa      11,Y

INITP2              lds       #P2stack
                    ldx       #P2
                    pshx
                    clra
                    psha:7
                    ldy       #PROCTBL
                    tsx
                    stx       12,Y
                    ldaa      #0
                    staa      14,Y
                    staa      15,Y
                    ldaa      #0
                    staa      16,Y
                    staa      17,Y

INITP3              lds       #P3stack
                    ldx       #P3
                    pshx
                    clra
                    psha:7
                    ldy       #PROCTBL
                    tsx
                    stx       18,Y
                    ldaa      #0
                    staa      20,Y
                    staa      21,Y
                    ldaa      #0
                    staa      22,Y
                    staa      23,Y

INITP4              lds       #P4stack
                    ldx       #P4
                    pshx
                    clra
                    psha:7
                    ldy       #PROCTBL
                    tsx
                    stx       24,Y
                    ldaa      #0
                    staa      26,Y
                    staa      27,Y
                    ldaa      #0
                    staa      28,Y
                    staa      29,Y

INITP5              lds       #P5stack
                    ldx       #P5
                    pshx
                    clra
                    psha:7
                    ldy       #PROCTBL
                    tsx
                    stx       30,Y
                    ldaa      #0
                    staa      32,Y
                    staa      33,Y
                    ldaa      #0
                    staa      34,Y
                    staa      35,Y

INITP6              lds       #P6stack
                    ldx       #P6
                    pshx
                    clra
                    psha:7
                    ldy       #PROCTBL
                    tsx
                    stx       36,Y
                    ldaa      #0
                    staa      38,Y
                    staa      39,Y
                    ldaa      #0
                    staa      40,Y
                    staa      41,Y

INITP7              lds       #P7stack
                    ldx       #P7
                    pshx
                    clra
                    psha:7
                    ldy       #PROCTBL
                    tsx
                    stx       42,Y
                    ldaa      #0
                    staa      44,Y
                    staa      45,Y
                    ldaa      #0
                    staa      46,Y
                    staa      47,Y

                    ldaa      #0                  ; Initialize variables
                    staa      KVAR
                    staa      SVAR
                    ldx       #OPTION
                    bset      0,X,%10000000
                    ldaa      #%00000111
                    staa      ADCTL
                    staa      DDRC
                    staa      DEB
                    staa      BUFFPTR
                    ldaa      #7
                    staa      PROCNUM

                    jsr       LCD_INI             ; Initialize the LCD

                    ldx       #WLCM               ; Intro Message to LCD
                    ldab      #15
                    jsr       LCDOUT

                    bsr       WSND

ENDB                cli                           ; Enable interrupts
                    jmp       P7                  ; Start with P7

WSND                ldaa      #30                 ; Welcome Sound
                    ldab      #30
                    jsr       PLAYSND
                    ldaa      #35
                    ldab      #28
                    jsr       PLAYSND
                    ldaa      #40
                    ldab      #26
                    bsr       PLAYSND
                    ldaa      #45
                    ldab      #24
                    bsr       PLAYSND
                    ldaa      #50
                    ldab      #22
                    bsr       PLAYSND
                    rts

; **************************
; Interrupt Service Routine
; **************************
ISR                 ldy       #PROCTBL            ; Increment process' CPU time
                    ldab      PROCNUM
                    addb:5    PROCNUM
                    aby
                    inc       3,Y
                    tsx                           ; Store state of process
                    stx       0,Y

ISR0                ldab      PROCNUM
                    cmpb      #0x00
                    bne       ISR1                ; Make sure process number doesn't go below 0
                    ldab      #8
ISR1                decb
                    stab      PROCNUM
                    addb:5    PROCNUM
                    ldy       #PROCTBL
                    aby
                    ldaa      2,Y
                    cmpa      #1                  ; Check if sleeping
                    beq       ISR0
ISR2                ldaa      4,Y
                    brclr     4,Y,%11111111,ISR3
                    deca
                    staa      4,Y
                    bra       ISR0

ISR3                ldaa      5,Y
                    staa      4,Y
ISR4                ldx       0,Y                 ; If not sleeping, run process
                    txs
                    ldaa      SVAR
                    cmpa      #0xFF
                    beq       INFL
                    ldaa      #%01000000
                    staa      TFLG2
                    rti

INFL                sei
                    bra       INFL

; ***********
; Processes
; ***********

;****************
; Sound Routine
;
PLAYSND             staa      SNDTMP
RETSND              ldaa      PORTA
                    oraa      #%00001000
                    staa      PORTA
                    ldaa      SNDTMP
UP                  jsr       WAIT20THMS
                    deca
                    cmpa      #0
                    beq       DOWNS
                    bra       UP

DOWNS               ldaa      PORTA
                    anda      #%11110111
                    staa      PORTA
                    ldaa      SNDTMP
DOWN                jsr       WAIT20THMS
                    deca
                    cmpa      #0
                    beq       DOWNE
                    bra       DOWN

DOWNE               decb
                    cmpb      #0
                    beq       ENDSND
                    bra       RETSND

ENDSND              rts


;************************
; P7: Serial Port Shell
;
P7                  ldx       #SCSR
P70                ;ldaa      #0xF7
;                   staa      MOTOR
                    brset     0,X,%00100000,P71
                    bra       P70

P71                 ldaa      SCDR
                    ldx       #BUFFER
                    ldab      BUFFPTR
                    abx
                    staa      0,X
                    incb
                    stab      BUFFPTR
                    ldx       #SCSR
                    cmpa      #0x0D
                    beq       P75
P72                 brset     0,X,%10000000,P73
                    bra       P72

P73                 staa      SCDR
P74                 brclr     0,X,%01000000,P7
                    bra       P74

P75                 brset     0,X,%10000000,P7501
                    bra       P75

P7501               ldaa      #0x0A
                    staa      SCDR
P76                 brclr     0,X,%01000000,P77
                    bra       P76

P77                 brset     0,X,%10000000,P770
                    bra       P77

P770                ldaa      #0x3E
                    staa      SCDR
P78                 brclr     0,X,%01000000,INPT
                    bra       P78

P7B                 ldaa      #0                  ; Clear input buffer and return
                    staa      BUFFPTR
                    bra       P7

; Check input buffer
INPT                ldab      BUFFPTR
                    cmpb      #3
                    beq       INPT1
                    cmpb      #5
;                   beq       ADCF
                    cmpb      #7
;                   beq       REBOOT
                    cmpb      #9
;                   beq       SHDOWNJ
                    cmpb      #10
;                   beq       MD
                    cmpb      #15
;                   beq       MM
                    bra       P7B

INPT1               ldx       #BUFFER
                    ldaa      0,X
                    cmpa      #0x70
                    beq       PS
                    cmpa      #0x73
                    beq       SX1
                    cmpa      #0x72
                    beq       RX1
                    bra       P7B

; Jump Extentions
SX1                 jmp       SX
RX1                 jmp       RX

; Display PS
PS                  ldab      #0
PS1                 ldx       #PSDAT
                    cmpb      #31
                    beq       PS2
                    abx
                    ldaa      0,X
                    jsr       SEND
                    incb
                    bra       PS1

PS2                 ldx       #PROCTBL
                    ldab      #0
                    ldy       #PSLCD2
PS3                 ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    stab      CONVR               ; PID
                    jsr       CONV
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      2,X                 ; STATE
                    adda      #0x52               ; add 0x52 so: 0=>R & 1=>S
                    staa      0,Y                 ; store in PSLCD2
                    ldaa      2,X                 ; reload STATE
                    staa      CONVR
                    jsr       CONV
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      3,X                 ; CPUTIME
                    staa      CONVR
                    jsr       CONV
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      4,X                 ; AGE
                    staa      CONVR
                    jsr       CONV
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      #0x20
                    jsr       SEND
                    ldaa      5,X                 ; PRIORITY
                    staa      CONVR
                    jsr       CONV
                    ldaa      #0x0A
                    jsr       SEND
                    incb
                    cmpb      #8
                    beq       PSEX1
                    inx:6
                    iny
                    jmp       PS3

PSEX1               ldaa      KVAR
                    cmpa      #0xF0
                    beq       PSSD
PSEX                jsr       LCDCLR              ; PS to LCD
                    ldx       #PSLCD1
                    ldab      #16
                    jsr       LCDOUT              ; PSLCD1
                    jsr       LCDLINE2
                    ldx       #PSLCD2
                    ldaa      #0x20
                    staa      8,X
                    staa      9,X
                    staa      10,X
                    staa      11,X
                    staa      12,X
                    staa      13,X
                    ldaa      #0x50
                    staa      14,X
                    ldaa      #0x53
                    staa      15,X
                    ldab      #16
                    jsr       LCDOUT              ; PSLCD2
                    jmp       P7B

PSSD                ldaa      #0xFF
                    staa      SVAR
                    jmp       P7B

; Sleep PX
SX                  ldx       #BUFFER
                    ldab      1,X
                    subb      #0x30
                    ldx       #PROCTBL
                    stab      CONVR
                    addb:5    CONVR
                    abx
                    ldaa      #1
                    staa      2,X
                    jmp       P7B

; Run PX
RX                  ldx       #BUFFER
                    ldab      1,X
                    subb      #0x30
                    ldx       #PROCTBL
                    stab      CONVR
                    addb:5    CONVR
                    abx
                    ldaa      #0
                    staa      2,X
                    jmp       P7B

; Sends an ASCII value
SEND                pshy
SEND0               ldy       #SCSR
                    brset     0,Y,%10000000,SEND1
                    bra       SEND0

SEND1               staa      SCDR
SEND2               brclr     0,Y,%01000000,SEND3
                    bra       SEND2

SEND3               puly
                    rts

; Convert Binary to ASCII and send
CONV                pshy
                    ldy       #SCSR
                    ldaa      CONVR
                    lsra
                    lsra
                    lsra
                    lsra
                    anda      #%00001111
                    cmpa      #9
                    ble       LT10
                    adda      #0x61
                    suba      #10
                    bra       CONVA

LT10                adda      #0x30
CONVA               brset     0,Y,%10000000,CONV0
                    bra       CONVA

CONV0               staa      SCDR
CONV1               brclr     0,Y,%01000000,CONV2
                    bra       CONV1

CONV2               ldaa      CONVR
                    anda      #%00001111
                    cmpa      #9
                    ble       LT102
                    adda      #0x61
                    suba      #10
                    bra       CONVB

LT102               adda      #0x30
CONVB               brset     0,Y,%10000000,CONV01
                    bra       CONVB

CONV01              staa      SCDR
CONV3               brclr     0,Y,%01000000,CONV4
                    bra       CONV3

CONV4               puly
                    rts

;************************
; P6
;
P6                  ldaa      #0xF6               ; Dummy
;                   staa      MOTOR
                    bra       P6

P5                  ldaa      #0xF5               ; Dummy
;                   staa      MOTOR
                    bra       P5

P4                  ldaa      #0xF4
;                   staa      MOTOR
                    bra       P4

P3                  ldaa      #0xF3               ; Dummy
;                   staa      MOTOR
                    bra       P3

P2                  ldaa      #0xF2               ; Dummy
;                   staa      MOTOR
                    bra       P2

P1                  ldaa      #0xF1               ; Dummy
;                   staa      MOTOR
                    bra       P1

P0                  ldaa      #0xF0               ; Dummy
;                   staa      MOTOR
                    bra       P0

; **************
; Wait Routines
;
WAIT                psha                          ; Wait 15 ms
                    tpa
                    psha
                    pshx
                    ldx       #15
WAIT1               bsr       WAIT1MS
                    dex
                    bne       WAIT1
                    pulx
                    pula
                    tap
                    pula
                    rts

WAIT1MS             psha                          ; Wait 1 ms
                    tpa
                    psha
                    pshx
                    ldx       #200
WAIT1MS1            dex
                    nop:2
                    bne       WAIT1MS1
                    pulx
                    pula
                    tap
                    pula
                    rts

WAIT2MS             psha                          ; Wait 2ms
                    tpa
                    psha
                    pshx
                    ldx       #400
WAIT2MS1            dex
                    nop:2
                    bne       WAIT2MS1
                    pulx
                    pula
                    tap
                    pula
                    rts

WAIT20THMS          psha                          ; Wait 1/20th ms
                    tpa
                    psha
                    pshx
                    ldx       #10
WAIT20THMS1         dex
                    nop:2
                    bne       WAIT20THMS1
                    pulx
                    pula
                    tap
                    pula
                    rts

; **************
; LCD Rountines
;
LCD_INI            ;jsr       WAIT                ;LCD Initialization Sequence
;                   ldaa      #%00110010
;                   jsr       LCDWR
;                   jsr       WAIT2MS
;                   jsr       WAIT2MS
;                   jsr       WAIT2MS
;                   ldaa      #%00110010
;                   jsr       LCDWR
;                   jsr       WAIT1MS
;                   ldaa      #%00110010
;                   jsr       LCDWR
;                   jsr       WAIT1MS
;                   ldaa      #%00100010
;                   jsr       LCDWR
;                   jsr       WAIT1MS
;                   ldaa      #%00100010      ;Now in 4-bit mode
;                   jsr       LCDWR
;                   ldaa      #%10000010
;                   jsr       LCDWR
;                   ldaa      #%00000010      ;Display Off
;                   jsr       LCDWR
;                   ldaa      #%10000010
;                   jsr       LCDWR
;                   ldaa      #%00000010      ;Return home
;                   jsr       LCDWR
;                   ldaa      #%00100010
;                   jsr       LCDWR
;                   ldaa      #%00000010      ;Entry mode set
;                   jsr       LCDWR
;                   ldaa      #%01100010
;                   jsr       LCDWR
;                   ldaa      #%00000010      ;turn display on
;                   jsr       LCDWR
;                   ldaa      #%11110010
;                   jsr       LCDWR
;                   jsr       LCDCLR
                    rts

LCDLINE2           ;ldaa      #%11000010          ;Jump to line 2
;                   jsr       LCDWR
;                   ldaa      #%00010010
;                   jsr       LCDWR

;                   ldaa      #%00010010          ;Shift left
;                   jsr       LCDWR
;                   ldaa      #%00000010
;                   jsr       LCDWR
                    rts

LCDCLR             ;ldaa      #%00000010          ;Clear display
;                   jsr       LCDWR
;                   ldaa      #%00010010
;                   jsr       LCDWR
                    rts

LCDWR              ;staa      PORTF               ;Write value in A to LCD
;                   jsr       WAIT1MS
;                   anda      #%11111101
;                   staa      PORTF
;                   jsr       WAIT1MS
                    rts

LCDOUT             ;cmpb      #0                  ;Load address of string into X and length into B before calling
;                   beq       LCOEX
;                   ldaa      0,X
;                   anda      #%11110000
;                   oraa      #%00000011
;                   jsr       LCDWR
;                   ldaa      0,X
;                   lsla
;                   lsla
;                   lsla
;                   lsla
;                   anda      #%11110000
;                   oraa      #%00000011
;                   jsr       LCDWR
;                   inx
;                   decb
;                   bra       LCDOUT
LCOEX               rts
