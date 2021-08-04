;
; ADC testing, LED on PA6
;

.include "tn20def.inc"

.def temp = r18
.def temp2 = r19
.def temp3 = r22
.def direc = R20
.def rw = R21
.def highbyte = r17
.def lowbyte = r25
.def ledstat = r23
.def init = r24
.def addr = r16
.equ d1 = 0x8F
.equ d2 = 0x04
.equ tmr = 0x2E

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
rjmp ADC_ISR ; Address 0x000D
reti;rjmp TWI_SLAVE_ISR ; Address 0x000E
reti;rjmp SPI_ISR ; Address 0x000F
reti;rjmp QTRIP_ISR ; Address 0x0010
rjmp loop


INITPROG:
    ;initialize stack pointer
    ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16
    ldi temp, 0xC2
    out DDRA, temp ;set both LEDs as output (PA6 and PA7)
    in direc,DDRA
    ;sbi PORTA,PORTA6 ;turn on PA6
    ;ADC stuff
    ldi temp, 0x03
    out ADMUX, temp ;set PA3 as input to ADC
    ;ldi temp, 0x93
    ldi temp, 0x00
    out ADCSRA, temp ;enable ADC, divide by 8 - clock runs at 1 mhz => divide by 8 to get nice input to adc (125 khz)
    ;cbi ADCSRA, ADIE
    ldi temp, 0x08
    out PUEA, temp ;set pull-up resistor
    sbi ADCSRB,ADLAR ;left align results, just have to read ADCH for 8-bit resolution
    
    ;just clock things
    ldi temp, 0x05 ;divide clock by 1024
    out TCCR0B,temp
    ldi temp, 0x02
    out TCCR0A, temp
    ldi temp, tmr ;set counter = 255
    out OCR0A, temp
    ;ldi temp, 0x0C
    ;out TCCR1B, temp ;set up 2nd timer for adc, divide by 256
    ;ldi temp,0x00
    ;out OCR1BH, temp
    ;ldi temp, tmr
    ;out OCR1BL, temp ;load in same value to trigger ADC counts
    ;in temp, TIMSK
    ldi temp, 0x02
    out TIMSK, temp ;set interrupt flag for timer 0
    
    sei
    rjmp loop

loop:
    ;rcall toggle_led
    ;cli
    rcall i2c_start_transmission
    rcall i2c_write_address
    rcall i2c_wait_for_ack
    cli
    mov r16, highbyte
    mov temp2, lowbyte
    ;ldi r16, 0x27
    sei
    ldi temp, 0xDB ;turn on ADC interrupt
    out ADCSRA,temp
    rcall i2c_write_byte
    rcall i2c_wait_for_ack
    mov addr, temp2
    add addr, ledstat
    rcall i2c_write_byte
    rcall i2c_wait_for_ack
    rcall i2c_send_stop
    ;ldi temp, 0xDB ;turn on ADC interrupt
    ;out ADCSRA,temp
    ;sei
    rcall delay
    rjmp loop

i2c_start_transmission:
    ori direc, 0x20
    out DDRA,direc ;set SDA as output
    in rw, PORTA
    rcall sda_high
    rcall scl_high
    rcall sda_low
    ret


i2c_write_address: ;address in r16
    ;for now hard code the address + write as 0xD0 = 0b11010000 (addr = 0x68)
    ldi r16, 0xD0
    ldi r18, 9
    rcall write_loop
    rcall scl_low
    ret

i2c_wait_for_ack:
    cli
    in direc,DDRA
    andi direc, 0xDF ;set SDA as input
    out DDRA,direc
    sei

    rcall scl_high
    in R22, PINA ;get ack bit

    rcall scl_low

    ret ;readings in R22

i2c_write_byte: ;address in r16
    ori direc, 0x20 ;set SDA as output
    out DDRA,direc

    ldi r18, 9
    ;ldi r16, 0x27
    rcall write_loop

    rcall scl_low
    ret

write_loop: ;r16 has value
    rcall scl_low
    dec r18
    brne sda_sel
    ret

sda_sel:
    lsl r16
    brcc write_low
    rcall sda_high
    rcall scl_high
    rjmp write_loop

write_low:
    rcall sda_low
    rcall scl_high
    rjmp write_loop

i2c_send_stop:
    ori direc, 0x20
    out DDRA,direc ;set SDA as output

    rcall sda_low
    rcall scl_high
    rcall sda_high
    andi direc, 0xDF ;set SDA as input
    out DDRA,rw

    ret

sda_low:
    andi rw, 0xDF
    out PORTA, rw
    ret

sda_high: 
    ori rw, 0x20
    out PORTA, rw
    ret

scl_low:
    andi rw, 0xFD
    out PORTA, rw
    ret

scl_high:
    ori rw, 0x02
    out PORTA, rw
    ret

delay:
	; not really needed, but keep r16-r18
	ldi temp2, d1
	ldi temp3, d2
	; start delay loop
delayLoop:
	subi temp2, 1 ; subtract 1
	sbci temp3, 0 ; if r16 was 0, subtract 1
	brne delayLoop ; while r18 is not 0, loop
	; end delay loop
	ret

toggle_led:
    push temp2
    in temp2, PORTA
    tst ledstat
    brne swap_1
    ori temp2, 0x40;nop
    andi temp2, 0x7F;nop
    out PORTA,temp2
    inc ledstat;ldi ledstat,1
    rjmp fin_tog
fin_tog:
    pop temp2
    ret

swap_1:
    ;PA7 off, PA6 on
    ori temp2, 0x80
    andi temp2,0xBF
    out PORTA,temp2
    clr ledstat ;nop
    rjmp fin_tog


toggle_led_2:
    push temp3
    push temp2
    ldi temp3, 0x80 ;PA7
    in temp2, PORTA
    eor temp2, temp3
    out PORTA, temp2
    pop temp2
    pop temp3
    ret

ADC_ISR:
    push temp
    in temp,SREG
    push temp
    ldi temp, 0x00 ;need to disable ADC in the interrupt!!
    out ADCSRA, temp
    in lowbyte, ADCL
    in highbyte, ADCH
    pop temp
    out SREG, temp
    pop temp
    reti

TIM0_COMPA_ISR:
    push temp
    in temp,SREG
    push temp
    ; turn on red LED
    ;rcall toggle_led_2
    rcall toggle_led
    pop temp
    out SREG, temp
    pop temp
    reti