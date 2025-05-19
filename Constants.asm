; Memory spaces
WRAM_ADDR:	equ $FF0000		; Work memory starting address
JOY_CTRL:	equ $A10009		; 1P control port
JOY_DATA:	equ $A10003   	; 1P data port
SYS_STACK:	equ $000000
REG_DUMP:	equ $FF0000
REG_PREFIXES:	equ $FF0042

; Various memory space sizes in bytes
WRAM_SIZE: 	equ 65536
VRAM_SIZE:	equ 65536
VSRAM_SIZE:	equ 80
CRAM_SIZE:	equ 128

; VDP memory spaces
VDP_DATA:    	equ $C00000		; VDP data port
VDP_CTRL:    	equ $C00004		; VDP control port
VDP_HVCOUNTER:  equ $C00008		; H/V counter

VRAM:	equ	$40000000	; Video memory address control
VSRAM:	equ $40000010	; Vertical scroll memory address control
CRAM: 	equ $C0000000	; Color memory address control

VRAM_DMA_CMD:   equ $40000080	; DMA VRAM control
VSRAM_DMA_CMD:  equ $40000090	; DMA VSRAM control
CRAM_DMA_CMD:   equ $C0000080	; DMA CRAM control

PLANEA_ADDR:	equ $E000		; Plane A name table address
PLANEB_ADDR:	equ $FFFF		; Plane B name table address
SPRITE_ADDR:	equ $FFFF		; Sprite name table address
WINDOW_ADDR:	equ $FFFF		; Window plane name table address
HSCROLL_ADDR:	equ $FFFF		; Plane x coordinate

; VDP registers
VDPREG_MODE1:     equ $8000  ; Mode register #1
VDPREG_MODE2:     equ $8100  ; Mode register #2
VDPREG_MODE3:     equ $8B00  ; Mode register #3
VDPREG_MODE4:     equ $8C00  ; Mode register #4

VDPREG_PLANEA:    equ $8200  ; Plane A table address
VDPREG_PLANEB:    equ $8400  ; Plane B table address
VDPREG_SPRITE:    equ $8500  ; Sprite table address
VDPREG_WINDOW:    equ $8300  ; Window table address
VDPREG_HSCROLL:   equ $8D00  ; HScroll table address

VDPREG_SIZE:      equ $9000  ; Plane A and B size
VDPREG_WINX:      equ $9100  ; Window X split position
VDPREG_WINY:      equ $9200  ; Window Y split position
VDPREG_INCR:      equ $8F00  ; Autoincrement
VDPREG_BGCOL:     equ $8700  ; Background color
VDPREG_HRATE:     equ $8A00  ; HBlank interrupt rate

VDPREG_DMALEN_L:  equ $9300  ; DMA length (low)
VDPREG_DMALEN_H:  equ $9400  ; DMA length (high)
VDPREG_DMASRC_L:  equ $9500  ; DMA source (low)
VDPREG_DMASRC_M:  equ $9600  ; DMA source (mid)
VDPREG_DMASRC_H:  equ $9700  ; DMA source (high)

; VDP name table addresses
NOFLIP: equ $0000  ; Don't flip (default)
HFLIP:  equ $0800  ; Flip horizontally
VFLIP:  equ $1000  ; Flip vertically
HVFLIP: equ $1800  ; Flip both ways (180° flip)

PAL0:   equ $0000  ; Use palette 0 (default)
PAL1:   equ $2000  ; Use palette 1
PAL2:   equ $4000  ; Use palette 2
PAL3:   equ $6000  ; Use palette 3

LOPRI:  equ $0000  ; Low priority (default)
HIPRI:  equ $8000  ; High priority

; Palette data sizes
PAT_BodyFont_SIZE_T:	equ 96
PAT_BodyFont_SIZE_B:	equ 96*32

; Z80 control
Z80Ram:     equ $A00000  ; Z80 RAM start
Z80BusReq:  equ $A11100  ; Z80 bus request line
Z80Reset:   equ $A11200  ; Z80 reset line

; Controller labels
JOY_C:	equ 5
JOY_B:	equ 4
JOY_R:	equ 3
JOY_L:	equ 2
JOY_D:	equ 1
JOY_U:	equ 0