;
; figure out how this nonsense ADC works
; 

.include "tn20def.inc"

.CSEG

.DEF LEDSTATUS = r24

.EQU delayMult1 = 0xff ; the delay is delay3*delaymult2*delaymult1 
.EQU delayMult2 = 0xff
.EQU delayMult3 = 0x01

.org 0x0000 ;Set address of next
rjmp INITPROG ; Address 0x0000
rjmp INT0_ISR ; Address 0x0001
rjmp PCINT0_ISR ; Address 0x0002
rjmp PCINT1_ISR ; Address 0x0003
rjmp WDT_ISR ; Address 0x0004
rjmp TIM1_CAPT_ISR ; Address 0x0005
rjmp TIM1_COMPA_ISR ; Address 0x0006
rjmp TIM1_COMPB_ISR ; Address 0x0007
rjmp TIM1_OVF_ISR ; Address 0x0008
rjmp TIM0_COMPA_ISR ; Address 0x0009
rjmp TIM0_COMPB_ISR ; Address 0x000A
rjmp TIM0_OVF_ISR ; Address 0x000B
rjmp ANA_COMP_ISR ; Address 0x000C
rjmp ADC_ISR ; Address 0x000D
rjmp TWI_SLAVE_ISR ; Address 0x000E
rjmp SPI_ISR ; Address 0x000F
rjmp QTRIP_ISR ; Address 0x0010
rjmp loop

INT0_ISR:
    reti
PCINT0_ISR:
    reti
PCINT1_ISR:
    reti
WDT_ISR:
    reti
TIM1_CAPT_ISR:
    reti
TIM1_COMPA_ISR:
    reti
TIM1_COMPB_ISR:
    reti
TIM1_OVF_ISR:
    reti
TIM0_COMPA_ISR:
    reti
TIM0_COMPB_ISR:
    reti
TIM0_OVF_ISR:
    reti
ANA_COMP_ISR:
    reti
TWI_SLAVE_ISR:
    reti
SPI_ISR:
    reti
QTRIP_ISR:
    reti

INITPROG:
    cli
    ;set up stack
    ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16

    ;set up pins
    ;PA1 = blue led, PA3 = ADCin, PA5 = red led
    ldi r18, (1<<DDA5) | (1<<DDA1) ;configure PA1,5 as outputs, PA3 as input
    out DDRA, r18
    ldi r18, (1<<PUEA3) ;attach pull-up resistor on PA3/ADC input
    out PUEA, r18

    ldi LEDSTATUS, 0x00
    ldi r18, (1<<PA1)
    out PORTA,r18

    ;delay just to make sure this is working 
    rcall delay

    ldi r18, 0x00
    out PORTA,r18
    rcall delay

     ;set up adc
    ldi r16, 0b11101011
    out ADCSRA,r16
    ldi r16,0b0000011
    out ADMUX,r16
    sei
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

loop:
    rjmp loop

ADC_ISR:
    in r16, SREG
    push r16
    rcall ledHi
    in r16, ADCL ;low ADC bits
    in r17, ADCH ;high ADC bits
    mov r22,r16
    rcall pause ;just a vis. indication of what the adc is reading
    mov r16,r22
    ;rcall pause
    ldi r16, 0x0f
    ldi r17, 0x0f
    rcall ledLow
    pop r16
    out SREG,r16
    reti
    ;breq turnLedHigh
    ;rjmp turnLedLow

ledHi:
    ldi r18, 1<<PA5
    out PORTA, r18
    ret
ledLow:
    ldi r18,0x00
    out PORTA,r18
    ret

turnLedLow:
    ldi LEDSTATUS, 0x00
    ldi r18, 0x00
    out PORTA, r18
    rjmp popem

turnLedHigh:
    ldi LEDSTATUS, 0x01
    ldi r18,0x00
    out PORTA,r18
    rjmp popem

popem:
    pop r16
    out SREG,r16
    pop r18
    pop r16
    ret

pause:
    dec r16
    brne pause
    ret



