;
;blink attiny20 on pin A1
;

.include "tn20def.inc"

.CSEG
.ORG $0000

.EQU delayMult1 = 0xff ; the delay is delay3*delaymult2*delaymult1 
.EQU delayMult2 = 0xff
.EQU delayMult3 = 0x01
.DEF LED_STATUS r4

main:
; set up the stack
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16

    ; set clock divider
	ldi r16, 0x00 ; clock divided by 1
	ldi r18, 0xD8 ; the key for CCP
	out CCP, r18 ; Configuration Change Protection, allows protected changes
	out CLKPSR, r16 ; sets the clock divider

    ldi r18, (1<<DDA5) | (1<<DDA1)
    
    out DDRA,r18

    nop

    rjmp loop

loop:
    ldi r16, 1<<PA1
    out PORTA, r16
    rcall delay

    ldi r16, 1<< PA5
    out PORTA, r16
    rcall delay
    rjmp loop

    ;ldi r17, 1<<PA1
    ;ldi r16,(1<<PUEA1)
    ;out PORTA,r17
    ;out PUEA, r16
    ;nop

    rjmp loop

delay:
    ldi r16, delayMult1
    ldi r17, delayMult2
    ldi r18, delayMult3

delayLoop:
    subi r16,1
    sbci r17,0
    sbci r18,0
    brne delayLoop
    ret