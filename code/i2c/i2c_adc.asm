;
; ADC testing, input on PA5 for now, led on PA1
;

.include "tn20def.inc"

.def temp = r18
.def temp2 = r19
.def direc = R20
.def rw = R21
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
    eor temp2,temp ;toggle LED using XOR (aka eor) - actually have no clue how this works since i never set temp
    out PORTA,temp2
    reti

INITPROG:
    ldi temp, 0x02
    out DDRA, temp ;set LED as output
    ldi temp, 0x02
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
    out TIMSK, temp ;set interrupt flag

    ;for i2c setup
    ldi direc, 0x02 ;set SCL as output
    out DDRA, direc

    sei
    rjmp loop

loop:
    ;out PORTA,temp2

    rjmp loop

i2c_start_transmission:
    in direc, DDRA
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
    andi direc, 0xDF ;set SDA as input
    out DDRA,direc

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

    