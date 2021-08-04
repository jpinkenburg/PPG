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
.equ d3 = 0x05

setup:
    ldi direc, 0x02 ;set SCL as output
    out DDRA, direc

loop:
    rcall write_address
    rcall wait_for_ack
    rcall write_byte
    rcall wait_for_ack
    rcall send_stop
    rcall delay
    rjmp loop



write_address: ;address in r16
    ;initialization
    in direc, DDRA
    ori direc, 0x20
    out DDRA,direc ;set SDA as output
    in rw, PORTA
    ori rw, 0x20 ;write SDA high
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw
    andi rw, 0xDF ;write SDA low
    out PORTA,rw

    ;for now hard code the address + write as 0xD0 = 0b11010000 (addr = 0x68)
    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ori rw,0x20 ;1st bit => 1
    out PORTA,rw
    ori rw, 0x02 ;writs SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ori rw,0x20 ;2nd bit => 1
    out PORTA,rw
    ori rw, 0x02 ;writs SCL high
    out PORTA,rw
    
    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    andi rw,0xDF ;3rd bit => 0
    out PORTA,rw
    ori rw, 0x02 ;writs SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ori rw,0x20 ;4th bit => 1
    out PORTA,rw
    ori rw, 0x02 ;writs SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    andi rw,0xDF ;5th bit => 0
    out PORTA,rw
    ori rw, 0x02 ;writs SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    andi rw,0xDF ;6th bit => 0
    out PORTA,rw
    ori rw, 0x02 ;writs SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    andi rw,0xDF ;7th bit => 0
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    andi rw,0xDF ;8th bit => 0
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw


    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ret

wait_for_ack:
    andi direc, 0xDF ;set SDA as input
    out DDRA,direc

    ori rw, 0x02 ; write SCL high
    out PORTA,rw
    in R22, PINA ;get ack bit

    andi rw, 0xFD ;write SCL low
    out PORTA,rw

    ret ;readings in R22

write_byte: ;hard coded as 0x2F = 0b00100111
    ori direc, 0x20 ;set SDA as output
    out DDRA,direc

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    andi rw,0xDF ;1st bit => 0
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    andi rw,0xDF ;2nd bit => 0
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ori rw,0x20 ;3rd bit => 1
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    andi rw,0xDF ;4th bit => 0
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ori rw,0x20 ;5th bit => 1
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ori rw,0x20 ;6th bit => 1
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ori rw,0x20 ;7th bit => 1
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ori rw,0x20 ;8th bit => 1
    out PORTA,rw
    ori rw, 0x02 ;write SCL high
    out PORTA,rw

    andi rw, 0xFD ;write SCL low
    out PORTA,rw
    ret

send_stop:
    ori direc, 0x20
    out DDRA,direc ;set SDA as output

    andi rw, 0xDF ;set SDA low
    out PORTA,rw
    ori rw, 0x02 ;SCL high
    out PORTA,rw
    ori rw, 0x20 ;SDA high
    out PORTA,rw
    andi direc, 0xDF ;set SDA as input
    out DDRA,rw

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