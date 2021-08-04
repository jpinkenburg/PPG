;
; bitbang I2C for ATtiny20
; SCL = PA1, SDA = PA5
; need pull-up resistors from SCL and SDA to VCC
;

.include "tn20def.inc"

.CSEG
.def direc = R20
.def rw = R21
.equ d1 = 0xFF
.equ d2 = 0xFF
.equ d3 = 0x01

setup:
    ldi direc, 0x02 ;set SCL as output
    out DDRA, direc

loop:
    rcall start_transmission
    rcall write_address
    rcall wait_for_ack
    ldi r16, 0x48
    rcall write_byte
    rcall wait_for_ack
    ldi r16, 0x45
    rcall write_byte
    rcall wait_for_ack
    ldi r16, 0x4C
    rcall write_byte
    rcall wait_for_ack
    ldi r16, 0x4C
    rcall write_byte
    rcall wait_for_ack
    ldi r16, 0x4F
    rcall write_byte
    rcall wait_for_ack
    rcall send_stop
    rcall delay
    rjmp loop


start_transmission:
    in direc, DDRA
    ori direc, 0x20
    out DDRA,direc ;set SDA as output
    in rw, PORTA
    rcall sda_high
    rcall scl_high
    rcall sda_low
    ret


write_address: ;address in r16
    ;for now hard code the address + write as 0xD0 = 0b11010000 (addr = 0x68)
    ldi r16, 0xD0
    ldi r18, 9
    rcall write_loop
    rcall scl_low
    ret

wait_for_ack:
    andi direc, 0xDF ;set SDA as input
    out DDRA,direc

    rcall scl_high
    in R22, PINA ;get ack bit

    rcall scl_low

    ret ;readings in R22

write_byte: ;address in r16
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

send_stop:
    ori direc, 0x20
    out DDRA,direc ;set SDA as output

    rcall sda_low
    rcall scl_high
    rcall sda_high
    andi direc, 0xDF ;set SDA as input
    out DDRA,rw

    ret

send_stop:
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
