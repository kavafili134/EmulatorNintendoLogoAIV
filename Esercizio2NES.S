.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
 ;  necro_6502.exe .\NES\Esercizio2NES.S .\NES\Esercizio2NES.bin
.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define OAMDMA $4014

.define JOYPAD1 $4016
.define JOYPAD2 $4017

.define SCROLL_X $00
.define SCROLL_Y $01
.define buttons $02

.define byteNameTable $03
.define byteTile $04
.define forIndex1 $05
.define forIndex2 $06


start:
    ; Set up PPU and Joypad 1 for reading input from the controller port 1 (the one on the left)
    LDA #%10000000
    STA PPUCTRL
    ; Set up PPU and Joypad 2 for reading input from the controller port 2 (the one on the right)
    LDA #%00011110
    STA PPUMASK
    
    ; load background palette
    LDA #$3F
    STA PPUADDR
    LDA #0 
    STA PPUADDR

    ; load sprite palette
    LDA #$19 
    STA PPUDATA
    LDA #$05
    STA PPUDATA
    LDA #$28
    STA PPUDATA
    LDA #$0F
    STA PPUDATA

    ; load first sprite palette
    LDA #$3f
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    ; load second sprite palette
    LDA #$21
    STA PPUDATA
    LDA #$22
    STA PPUDATA
    LDA #$23
    STA PPUDATA
    LDA #$24
    STA PPUDATA

     ; load sprite tiles
     LDA #0
     STA OAMADDR
     LDA #$22
     STA OAMDATA
     LDA #$82
     STA OAMDATA
     LDA #%10000001
     STA OAMDATA
     LDA #$22
     STA OAMDATA

    LDA #$20
    STA byteNameTable
    LDA #$00
    STA byteTile
    JSR drawImage
    LDA #$24
    STA byteNameTable
    LDA #$00
    STA byteTile
    JSR drawImage


loop:
    JMP loop

drawImage:
    LDA #%10000100 ; set PPUCTRL to enable background and sprites
    STA PPUCTRL ; and set the background to be 4 screen mode
    LDX #$10 ; set X to 16
    STX forIndex1 ; store X in forIndex1
    STX forIndex2 ; store X in forIndex2
draw_page_out_loop:
    LDA byteNameTable ; load byteNameTable into A
    STA PPUADDR ; store A into PPUADDR
    LDA byteTile ; load byteTile into A
    STA PPUADDR ; store A into PPUADDR
    draw_page_in_loop:
        LDA byteTile ; load byteTile into A
        STA PPUDATA ; store A into PPUDATA
        CLC ; clear carry flag
        ADC #$10 ; add 16 to A
        STA byteTile ; store A into byteTile
        ;intruzioni per disegnare la pagina
        DEC forIndex1 ; decrement forIndex1
        BNE draw_page_in_loop ; branch if not zero
    ; istruzione OutLoop
    INC byteTile ; increment byteTile
    LDX #$10 ; set X to 16
    STX forIndex1 ; store X in forIndex1
    DEC forIndex2 ; decrement forIndex2
    BNE draw_page_out_loop ; branch if not zero
RTS

readjoy:
    LDA #$01
    STA JOYPAD1
    STA buttons
    LSR A
    STA JOYPAD1
joyloop:
    LDA JOYPAD1
    LSR A
    ROL buttons
    BCC joyloop
    RTS

nmi:
    PHA 
    JSR readjoy
    PLA

right_check:
    LDA buttons
    AND #%00000001
    BEQ left_check
    LDA #3
    STA OAMADDR
    LDA SCROLL_X
    CMP #250
    BEQ border_check
    JMP increment_scroll
    increment_scroll:
    INC SCROLL_X
    STA OAMDATA
left_check:
    LDA buttons
    AND #%00000010
    BEQ down_check
    LDA #3
    STA OAMADDR
    LDA SCROLL_X
    CMP #0
    BEQ border_check
    JMP decrement_scroll
    decrement_scroll:
    DEC SCROLL_X
    STA OAMDATA
down_check:
    LDA buttons
    AND #%00000100
    BEQ up_check
    LDA #0
    STA OAMADDR
    LDA SCROLL_Y
    CMP #225
    BEQ border_check
    JMP increment_scroll_y
    increment_scroll_y:
    INC SCROLL_Y
    STA OAMDATA
up_check:
    LDA buttons
    AND #%00001000
    BEQ end_check
    LDA #0
    STA OAMADDR
    LDA SCROLL_Y
    CMP #6
    BEQ border_check
    JMP decrement_scroll_y
    decrement_scroll_y:
    DEC SCROLL_Y
    STA OAMDATA
end_check:
    LDA SCROLL_X
    STA PPUSCROLL
    LDA SCROLL_Y
    STA PPUSCROLL
    RTI


border_check:
    RTI

irq:
    RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

;.incbin "C:/Users/kavaf/OneDrive/AIV_2022-2023/2022 - 2023 - 01 - LezioniProgetti/PYTHON_3ANNO/NES/mario0.chr"
.incbin "C:/Users/kavaf/OneDrive/AIV_2022-2023/2022 - 2023 - 01 - LezioniProgetti/PYTHON_3ANNO/NES/aiv256.chr"