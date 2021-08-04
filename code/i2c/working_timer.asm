;
; ADC testing, input on PA5 for now, led on PA1
;

.include "tn20def.inc"

.def temp = r18
.def temp2 = r19
.equ d1 = 0xFF
.equ d2 = 0xFF
.equ d3 = 0x00

.CSEG

.org 0x0000 ;Set address of next
rjmp INITPROG ; Address 0x0000
reti;rjmp INT0_ISR ; Address 0x0001
reti;rjmp PCINT0_ISR ; Address 0x0002
reti;rjmp PCINT1_ISR ; Address 0x0003
reti;rjmp WDT_ISR ; Address 0x0004
reti;rjmp TIM1_CAPT_ISR ; Address 0x0005
reti;rjmp TIM1_COMPA_ISR ; Address 0x0006
reti;rjmp TIM1_COMPB_ISR ; Address 0x0007
reti;rjmp TIM1_OVF_ISR ; Address 0x0008
rjmp TIM0_COMPA_ISR ; Address 0x0009
reti;rjmp TIM0_COMPB_ISR ; Address 0x000A
reti;rjmp TIM0_OVF_ISR ; Address 0x000B
reti;rjmp ANA_COMP_ISR ; Address 0x000C
reti;rjmp ADC_ISR ; Address 0x000D
reti;rjmp TWI_SLAVE_ISR ; Address 0x000E
reti;rjmp SPI_ISR ; Address 0x000F
reti;rjmp QTRIP_ISR ; Address 0x0010
rjmp loop

TIM0_COMPA_ISR:
    ; turn on LED
    in temp2,PORTA
    eor temp2,temp ;toggle LED using XOR (aka eor)
    out PORTA,temp2
    ;reset register
    ;in temp, TIFR
    ;andi temp, 0xFD
    ;out TIFR, temp
    ;ldi temp, 0xFF ;set counter = 255
    ;out OCR0A, temp
    reti

INITPROG:
    ldi temp, 0x02
    out DDRA, temp ;set LED as output
    ldi temp, 0x00
    out PORTA,temp
    in temp, TCCR0B
    ori temp, 0x05 ;divide clock by 1024
    out TCCR0B,temp
    ldi temp, 0x02
    out TCCR0A, temp
    ldi temp, 0xFE ;set counter = 255
    out OCR0A, temp
    in temp, TIMSK
    ori temp, 0x02
    sei
    out TIMSK, temp ;set interrupt flag
    rjmp loop

loop:
    rcall delay
    ;out PORTA,temp2
    rjmp loop

delay:
	; not really needed, but keep r16-r18
	
	ldi r23, d1
	ldi r24, d2
	ldi r25, d3

	; start delay loop
delayLoop:
	subi r23, 1 ; subtract 1
	sbci r24, 0 ; if r16 was 0, subtract 1
	sbci r25, 0 ; if r17 was 0, subtract 1
	brne delayLoop ; while r18 is not 0, loop
	; end delay loop
	ret


    