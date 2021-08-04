;
; ADC testing, LED on PA6
;

.include "tn20def.inc"

.def temp = r18
.def temp2 = r19
.def temp3 = r22
.def direc = R20
.def rw = R21
.def temp4 = r17
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

INITPROG:
    ldi temp, 0x40
    out DDRA, temp ;set LED as output
    ldi temp, 0x40
    out PORTA,temp
    ;in temp, TCCR0B
    ldi temp, 0x05 ;divide clock by 1024
    out TCCR0B,temp
    ldi temp, 0x02
    out TCCR0A, temp
    ldi temp, 0xFE ;set counter = 255
    out OCR0A, temp
    ;in temp, TIMSK
    ldi temp, 0x02
    out TIMSK, temp ;set interrupt flag
    ;for i2c setup
    in direc, DDRA
    ori direc, 0x02
    out DDRA, direc
    ;ADC stuff
    ldi temp, 0x03
    out ADMUX, temp ;set PA3 as input to ADC
    ldi temp, 0x93
    out ADCSRA, temp ;enable ADC, divide by 8 - clock runs at 1 mhz => divide by 8 to get nice input to adc (125 khz)
    ldi temp, 0x08
    out PUEA, temp ;set pull-up resistor
    sbi ADCSRB,ADLAR ;left align results, just have to read ADCH
    sei

loop:
    sbi ADCSRA, ADSC
    nop
while:
    ;ldi temp, ADCSRA
    in temp4, ADCSRA
    nop
    nop
    andi temp4, 0x10
    rjmp send_i2c
    rjmp while
send_i2c:
    in temp, ADCL
    nop
    in temp4, ADCH
    nop
    rcall i2c_start_transmission
    rcall i2c_write_address
    rcall i2c_wait_for_ack
    ;ldi r16, 0x22
    mov r16, temp
    nop
    ;ldi r16, 0x10
    ;in temp, ADCH
    rcall i2c_write_byte
    rcall i2c_wait_for_ack
    mov r16, temp4
    nop
    rcall i2c_write_byte
    rcall i2c_wait_for_ack
    rcall i2c_send_stop
    rcall delay
    rjmp loop

i2c_start_transmission:
    in direc, DDRA
    ori direc, 0x20
    out DDRA,direc ;set SDA as output
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
    in direc, DDRA
    andi direc, 0xDF ;set SDA as input
    out DDRA,direc

    rcall scl_high
    in R22, PINA ;get ack bit

    rcall scl_low

    ret ;readings in R22

i2c_write_byte: ;address in r16
    in direc, DDRA
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
    in direc, DDRA
    ori direc, 0x20
    out DDRA,direc ;set SDA as output

    rcall sda_low
    rcall scl_high
    rcall sda_high
    in rw, DDRA
    andi rw, 0xDF ;set SDA as input
    out DDRA,rw

    ret

sda_low:
    in rw,PORTA
    andi rw, 0xDF
    out PORTA, rw
    ret

sda_high: 
    in rw, PORTA
    ori rw, 0x20
    out PORTA, rw
    ret

scl_low:
    in rw, PORTA
    andi rw, 0xFD
    out PORTA, rw
    ret

scl_high:
    in rw, PORTA
    ori rw, 0x02
    out PORTA, rw
    ret

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

TIM0_COMPA_ISR:
    ; turn on LED
    ldi temp3, 0x40
    in temp2,PORTA
    eor temp2,temp3 ;toggle LED using XOR (aka eor) - actually have no clue how this works since i never set temp
    out PORTA,temp2
    reti