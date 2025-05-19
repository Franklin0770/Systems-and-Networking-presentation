	cpu 68000
	
	supmode on	; We don't need warnings about privileged instructions
	
	include "ComplierMacros.asm"
	include "MegaDriveMacros.asm"
	include "Constants.asm"

	org 0
	
ROM_Start:																	; Error codes ($AAxx)
Vectors:
		dc.l SYS_STACK		; Initial stack pointer value (SP value)
		dc.l EntryPoint			; Start of program (PC value)
		dc.l BusError			; Bus error									($2)
		dc.l AddressError		; Address error 							($3)
		dc.l IllegalInstruction	; Illegal instruction						($4)
		dc.l DivisionByZero		; Division by zero							($5)
		dc.l CHKException		; CHK exception								($6)
		dc.l TRAPVException		; TRAPV exception 							($7)
		dc.l PrivilegeViolation	; Privilege violation						($8)
		dc.l TRACEException		; TRACE exception							($9)
		dc.l Line1010Emu		; Line-A emulator							($A)
		dc.l Line1111Emu		; Line-F emulator 							($B)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved
		dc.l SpuriousException	; Spurious exception						($C)
		dc.l GenericError		; IRQ level 1
		dc.l GenericError		; IRQ level 2
		dc.l GenericError		; IRQ level 3 
		dc.l GenericError		; IRQ level 4 (horizontal retrace interrupt)
		dc.l GenericError		; IRQ level 5
		dc.l VDP_VBlankInt		; IRQ level 6 (vertical retrace interrupt)
		dc.l GenericError		; IRQ level 7
		dc.l GenericError		; TRAP #00 exception						($D)
		dc.l GenericError		; TRAP #01 exception
		dc.l GenericError		; TRAP #02 exception
		dc.l GenericError		; TRAP #03 exception
		dc.l GenericError		; TRAP #04 exception
		dc.l GenericError		; TRAP #05 exception
		dc.l GenericError		; TRAP #06 exception
		dc.l GenericError		; TRAP #07 exception
		dc.l GenericError		; TRAP #08 exception
		dc.l GenericError		; TRAP #09 exception
		dc.l GenericError		; TRAP #10 exception
		dc.l GenericError		; TRAP #11 exception
		dc.l GenericError		; TRAP #12 exception
		dc.l GenericError		; TRAP #13 exception
		dc.l GenericError		; TRAP #14 exception
		dc.l GenericError		; TRAP #15 exception
		dc.l GenericError		; Unused (reserved)							($E)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		dc.l GenericError		; Unused (reserved)
		
Header_Start:
		dc.b "SEGA MEGA DRIVE",$20					; "$20" is padding
		dc.b "(C)BRO0 2024.OCT"						; Copyright(-ish), release year and month
		dc.b "Presentazione sistemi: 68k e x86"		; Domestic name (it's Italian I know)
		dc.b "                "						; padding
		dc.b "Presentazione sistemi: 68k e x86"		; Overseas name (in Italian as well)
		dc.b "                "						; padding
		dc.b "AI-23456786-00"						; Serial number (I mashed the keyboard for this)
		dc.w $0000									; Empty checksum
		dc.b "J"									; Joypad type
		dc.b "               "						; padding
		dc.l ROM_Start								; Start address of ROM
		dc.l ROM_End								; End address of ROM
		dc.l $FF0000								; Start address of WRAM
		dc.l $FFFFFF 								; End address of WRAM
		dc.b "                                                                " ; more padding
		dc.b "E  "									; Region support (PAL only)
		dc.b "             "						; padding for reserved space

BusError:
	movem.l	d0-a7,REG_DUMP	; we need to force the dump address
	move sr,REG_DUMP+$40	; dump the status register also
	moveq	#2+$10,d7
	bra.w	VDP_BSOD

AddressError:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#3+$10,d7
	bra.w	VDP_BSOD

IllegalInstruction:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#4+$10,d7
	bra.w 	VDP_BSOD

DivisionByZero:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#5+$10,d7
	bra.w 	VDP_BSOD
	
CHKException:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#6+$10,d7
	bra.w	VDP_BSOD
	
TRAPVException:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#7+$10,d7
	bra.w	VDP_BSOD
	
PrivilegeViolation:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#8+$10,d7
	bra.s	VDP_BSOD
	
TRACEException:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#9+$10,d7
	bra.s	VDP_BSOD

Line1010Emu:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#$A+$10,d7
	bra.s	VDP_BSOD
	
Line1111Emu:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#$B+$10,d7
	bra.s	VDP_BSOD
	
SpuriousException:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#$C+$10,d7
	bra.s	VDP_BSOD
	
TRAPxxException:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#$D+$10,d7
	bra.s	VDP_BSOD
	
GenericError:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#$E+$10,d7
	bra.s	VDP_BSOD
	
ManualCrash:
	movem.l	d0-a7,REG_DUMP
	move sr,REG_DUMP+$40
	moveq	#$F+$10,d7

VDP_BSOD:
	lea	SYS_STACK,sp	; realign the stack pointer
	move #$2700,sr		; disable interrupts
	addq.b	#6,REG_PREFIXES+$4B	; add the value back to sp dump value
	lea VDP_CTRL,a0		; reset a0
	lea VDP_DATA,a1		; reset a1
	moveq	#0,d2		; clear slow down timer for CPU_ClearScreen
	move.l	#$FF,d3		; update the slow down timer for CPU_ClearScreen

; ---------------------------------------------------------------------------
; Subroutine to	clear the screen using CPU
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||
	
CPU_ClearScreen:
	vdpSetVideoAddress PLANEA_ADDR,(a0)
	move.w	#($1000/4)-1,d0	; clear the entire plane A ($1000 bytes)
	moveq	#0,d1		; clear d1
.clear_screen:
	move.l	d1,(a1)		; clear portion of screen by setting the background tiles
	move.w	d3,d2		; update the slow down timer for CPU_Wait
	bsr.w	CPU_Wait	; make the slow down effect
	dbf d0,.clear_screen	; keep clearing until done
	
	move.w	#$2FFF,d2	; update the slow down timer
	bsr.w	CPU_Wait	; a bit of lag

BlueScreen:
	vdpSetColorSpace 0,(a0)
	move.l	#$0E000EEE,(a1)	; makes the background blue and the font white
	
	move.l	#$2FFFF,d2	; update the slow down timer
	bsr.w	CPU_Wait	; a bit of lag
	
CPU_Load_BodyFont:
	vdpSetVideoAddress $0000,(a0)
	move.w	#PAT_BodyFont_SIZE_B/4,d0
	lea	(PAT_BodyFont),a2
	
.load_font:
	move.l	(a2)+,(a1)
	dbf d0,.load_font

; ---------------------------------------------------------------------------
; Subroutine to	print on screen the first five strings (messages)
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||

PrintMessages:	
	lea Messages,a2		; points to the string address in the properties array
	movea.l	a2,a3		; reset a5 (since we will write only in word operations)
	moveq	#0,d0		; clear the length register (cycle counter)
	moveq	#5-1,d4		; 5 strings to print (Message0 ~ Code)
.setup_message:
	move.w 	(a2),a3		; update the array of strings pointer
	move.w 	6(a2),d0	; get the next value into d0
	sub.w	a3,d0		; get the length from doing the difference
	subq.w	#1,d0		; dbf ends up with $FFFF
	; get string screen position address and set the plane A accordingly
    move.l	2(a2),(a0)	; update the plane coordinates using fixed value
	move.w	#$7FF,d3	; update the slow down timer for VDP_PrintText
	bsr.w	VDP_PrintText
	
	addq.w	#6,a2		; jump into next string (also skips the coordinates)
	move.w	#$1FFF,d2	; update the slow down timer
	bsr.w	CPU_Wait	; a bit of lag
	dbf d4,.setup_message
	
	move.w	#$2FFF,d2	; update the slow down timer
	bsr.w	CPU_Wait	; a bit of lag

; ---------------------------------------------------------------------------
; Subroutine to	print on screen the error code in hexadecimal
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||

PrintErrorCode
	move.l	#chars('A','A'),d0
	move.l	d0,(a1)		; print "AA"
	
	move.b	d7,d0		; move error code to be "Ax"
	
	cmpi.b	#$A+$10,d7	; is the error code a letter?
	blo.s	.continue	; if not do not align VRAM for letters
	addq.b	#7,d0		; align VRAM to print hexadecimal letters
.continue:
	move.l	d0,(a1)		; print the rest of the error code
	
	move.w	#$FFFF,d2	; update the slow down timer
	bsr.w	CPU_Wait	; a bit of lag

; ---------------------------------------------------------------------------
; Subroutine to	print on screen the error code in text
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||

PrintTextCode
	lea TextCodes,a2	; load text codes array
	subi.b	#$10+2,d7	; align d7 (VRAM alignment + how error codes count by design)
	lsl.b	#1,d7		; update incrementer for word jumps
	adda.w	d7,a2		; snipe the string address
	move.w	(a2),a3		; update the array of strings pointer
	move.w	2(a2),d0	; get next string address
	sub.w	a3,d0		; get the length from doing the difference
	subq.w	#1,d0		; dbf ends up with $FFFF
	move.l	#vdpCoordinates(2,7),(a0)	; set fixed text code position on screen
	move.w	#$8FF,d3	; update the slow down timer for VDP_PrintText
	bsr.w	VDP_PrintText
	
	move.w	#$FFFF,d2	; update the slow down timer
	bsr.w	CPU_Wait	; a bit of lag
	
; ---------------------------------------------------------------------------
; Subroutine to	print on screen the register names (or prefixes)
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||
	
PrintRegisterDump
.print_message:
	lea	Message5,a3	; points to the string address directly
	moveq	#15-1,d0	; this string is 15 characters long
	move.l	#vdpCoordinates(0,10),(a0)
	move.w	#$AFF,d3	; update the slow down timer for VDP_PrintText
	bsr.w	VDP_PrintText
	move.w	#$5FFF,d2	; update the slow down timer
	bsr.w	CPU_Wait	; a bit of lag

	moveq	#8-1,d0		; 8 registers to write
	moveq	#8-1,d6		; 8 digits to print
	moveq	#0,d5
	lea	(REG_PREFIXES+10),a2	; start from this point to write down the prefixes
	lea REG_DUMP,a3		; load register dump pointer
	; write the prefixes in RAM in opposite order
	move.l	#chars('0','x'),-(a2)
	move.w	#char(':'),-(a2)
	move.l	#chars('d','0'),-(a2)
	move.l	#vdpCoordinates(2,12),d1	; set on-screen register dump coordinates

;============================================================================

.print_registers:
	move.l	d1,(a0)		; update the plane coordinates

	moveq	#5-1,d3		; 5 prefixes to print
.print_prefix:
	move.w	(a2)+,(a1)	; print register number
	move.w	#$FFF,d2	; update the slow down timer
	bsr.w	CPU_Wait	; a bit of lag
	dbf d3,.print_prefix
	
	subaq	10,a2		; reposition a2 to the prefixes' start
	
; ---------------------------------------------------------------------------
; Subroutine to	print on screen the register values from dump
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||

    move.l	d6,d3		; update the digit counter
	move.l	(a3)+,d4	; get the register dumped value
.print_value:
	rol.l	#4,d4		; rotate the digits on the left
	move.b	d4,d5		; move the digits in ascending order to d5
	andi.b	#$F,d5		; remove the other digit
	
	cmpi.b	#$A,d5		; is the digit a letter?
	blo.s	.continue	; if not do not align VRAM for letters
	addq.b	#7,d5		; align VRAM to print letters
.continue:
	addi.b	#$10,d5		; align VRAM to print numbers or letters
	move.w	d5,(a1)		; update the plane A
	
	dbf d3,.print_value	; loop until printed all digits
	
	addq.b	#1,REG_PREFIXES+3	; increment register number character
	addi.l	#$800000,d1			; new line by adding coordinates
	
	move.w	#$1FFF,d2			; update the slow down timer
	bsr.w	CPU_Wait			; a bit of lag
	dbf d0,.print_registers

.print_address_registers
	cmpa.l	#REG_DUMP+$20,a3	; has the VDP already printed the address registers?
	bhi.s	.print_sp			; if yes, print stack pointer
	moveq	#7-1,d0				; 7 registers to print
	moveq	#8-1,d6				; 8 digits to print
	subq.b	#3,REG_PREFIXES+1	; change prefix from 'd' to 'a'
	subq.b	#8,REG_PREFIXES+3	; restart the count from 0
	move.l	#vdpCoordinates(19,12),d1	; update coordinates
	bra.w	.print_registers	; print address register dump
	
.print_sp:
	cmpa.l	#REG_DUMP+$3C,a3	; has the VDP already printed the stack pointer?
	bhi.s	.print_sr			; if yes, print the status register
	moveq	#1-1,d0				; 1 register to write
	moveq	#8-1,d6				; 8 digits to print
	move.l	#chars('s','p'),(a2)	; use "sp" prefix
	bra.w	.print_registers	; print sp
	
.print_sr:
	cmpa.l	#REG_DUMP+$40,a3	; has the VDP already printed the stack pointer?
	bhi.s 	Halt_CPU			; if yes, stop the execution
	moveq	#1-1,d0				; 1 register to write
	moveq	#4-1,d6				; 4 digits to print
	move.l	#chars('s','r'),(a2)		; use "sr" prefix
	move.l	#vdpCoordinates(2,22),d1	; set fixed coordinates
	bra.w	.print_registers
	
; ---------------------------------------------------------------------------
; Subroutine to	draw text on screen (a3: string pointer, d0: length)
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||

VDP_PrintText:
	moveq	#0,d1		; clear d1
.update_display:
	move.b 	(a3)+,d1	; move character to d1
	move.w 	d1,(a1)		; no flip, palette 0, no priority
	move.l	d3,d2		; update the slow down timer for CPU_Wait
	bsr.s	CPU_Wait	; make the slow down effect
	dbf	d0,.update_display
	rts

; ---------------------------------------------------------------------------
; Subroutine to	hang the CPU for a given time (d2: timer)
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||

CPU_Wait:
	subi.l	#1,d2		; purposefully using a slower instruction
	bne.s	CPU_Wait	; wait until done (dbf subs only word-wise, which is not suitable)
	rts
	
Halt_CPU:
	stop #$2700		; halt the CPU indefinitely

;---------------------------------------------------------------------------------

VDP_VBlankInt:
	rte

;=================================================================================

; Assets section

PAT_BodyFont: include "assets\Body Font.asm"

STR_Strings: include "assets\Strings.asm"

STR_Properties: include "assets\String Properties.asm"

;=================================================================================

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; | General registers purpose (because I hate RAM accesses)																															|
; | a0: VDP control port, a1: VDP data port, a2: controller control port, a3: controller data port, a4: string addresses array, a5: address string array, a6: unused				|
; | d7: contains $40 to request controller access, d6: controller state, d5: controller press tester, d4: VBlank tester, d3: zero writer, d2,d1,d0: generic purpose	|
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

EntryPoint:
CPU_RegistersDeclaration
	moveq 	#$40,d7
	moveq	#$7F,d5
	moveq	#3,d4
	moveq	#0,d3
	lea	VDP_CTRL,a0
	lea	VDP_DATA,a1
	lea JOY_CTRL,a2
	lea	JOY_DATA,a3
	lea STR_Properties,a4

VDP_Setup
	tst.w 	(a0) ; Testing the VDP control port safely resets it
	
	move.w  #VDPREG_MODE1|%00000100,(a0)	; Mode register #1
    move.w  #VDPREG_MODE2|%01111100,(a0)	; Mode register #2
    move.w  #VDPREG_MODE3|%00000000,(a0)	; Mode register #3
    move.w  #VDPREG_MODE4|%10000001,(a0)	; Mode register #4
    
    move.w  #VDPREG_PLANEA|(PLANEA_ADDR>>10),(a0)   ; Plane A address
    move.w  #VDPREG_PLANEB|(PLANEB_ADDR>>13),(a0)   ; Plane B address
	move.w  #VDPREG_SPRITE|(SPRITE_ADDR>>9),(a0)	; Sprite address
    move.w  #VDPREG_WINDOW|(WINDOW_ADDR>>10),(a0)	; Window address
    move.w  #VDPREG_HSCROLL|(HSCROLL_ADDR>>10),(a0)	; HScroll address
    
    move.w  #VDPREG_SIZE|%00000001,(a0)	; Tilemap size
	move.w  #VDPREG_WINX|$00,(a0)		; Window X split
    move.w  #VDPREG_WINY|$00,(a0)		; Window Y split
    move.w  #VDPREG_INCR|$02,(a0)		; Autoincrement
    move.w  #VDPREG_BGCOL|$00,(a0)		; Background color
	move.w  #VDPREG_HRATE|$FF,(a0)		; HBlank IRQ rate
	
JOY_Setup
	move.b 	d7,(a2)
	move.b 	d7,(a3)

;=================================================================================

DMA_Load_BodyFont
	dma68kToVDP PAT_BodyFont, $0000, PAT_BodyFont_SIZE_B, VRAM, FALSE, (a0), (a1)

CRAM_Load_BodyFontPalette
	vdpSetColorSpace 0,(a0)
	move.l	#$0000EEEE,(a1)	; black and white

	dmaFillVRAM $00, PLANEA_ADDR, $757, (a0), (a1) ; clears characters at every soft reset

	bra.w 	UpdateStringProperties
	;bra.s	PressWait	it already does this in UpdateStringProperties

;=================================================================================

; ---------------------------------------------------------------------------
; Subroutine to	read the controller and wait until the input is released
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||

GetJoypad:
	move.b 	d7,(a3)	; write $40 to request controller state
	nop	; wait for the bus to get the controller state
	nop
	nop
	nop
	move.b	(a3),d6	; put control state somewhere
	rts

; This portion of code was meant to change slide only by pressing the button once (not by holding, effectively avoiding debouncing).
; This is unnecessary, because the animation is slow enough to prevent accidental slide changes
;PressWait: 
;.press_wait:
;	stop	#$2500	; wait until next frame (can't make a frame-perfect press)
;	bsr.s	GetJoypad
;	cmp.b	d5,d6	; are there any pressed buttons? (d5 = %0111 1111)
;	bne.s	.press_wait
; End of function GetJoypad

; ---------------------------------------------------------------------------
; Subroutine to	perform the action according to the pressed button
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||

; Why is GetJoypad in the bottom of this routine?
; Because PressWait has already updated the controller state at this point.
ReadJoypad:
	bsr.s	GetJoypad
	btst 	#JOY_R,d6
	beq.s 	NextString
	btst	#JOY_L,d6
	beq.s	RedrawSlide
	btst	#JOY_U,d6
	beq.w	NextSlide
	btst 	#JOY_D,d6
	beq.w 	PreviousSlide
	btst 	#JOY_C,d6
	beq.w	ClearScreen_Alt
	btst 	#JOY_B,d6
	beq.w 	CPU_CrashSystem
WaitNextFrame:
	stop	#$2500		; wait until next frame
	bra.s 	ReadJoypad

RedrawSlide:
.find_terminator:
	tst.w	-(a4)
	bpl.s	.find_terminator
	bsr.s 	VDP_ClearScreen
	bra.s	UpdateStringProperties

NextString:
	cmpa.w	#Slide8+6,a4	; is the boundary limit to avoid going outside the slides being hit?
	bhs.s	WaitNextFrame	; if yes, do nothing
	;addq.w	#6,a4			already done by UpdateStringProperties
	
; ---------------------------------------------------------------------------
; Subroutine to	draw text on screen (a4: string pointer)
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||

UpdateStringProperties:
	move.w	(a4)+,d1	; get string address and move pointer
	tst.w	d1			; are we encountering an $FFFF terminator?
	bpl.s	.continue	; if no, continue
	move.w	(a4)+,d1	; update d1 and skip terminator
	bsr.s 	VDP_ClearScreen
.continue:
	movea.w	d1,a5		; update the array of strings pointer	
	move.w 	4(a4),d0	; get the next string address into d0 6(a4)
	tst.w	d0			; did d0 pick up an $FFFF terminator?
	bmi.s	SkipTerminator	; if yes, update strings skipping terminator
Continue:
	sub.w	d1,d0		; get the length by doing the difference
	subq.w	#1,d0		; dbf ends up with $FFFF
	; gets string screen position address and sets the plane A accordingly
    move.l	(a4)+,(a0)	; 2(a4) to avoid more spent cycles in adding 2 to a4
	
UpdateDisplay:
	move.l	d3,d1
.print_text: ; (30 cycles per loop)
	move.b 	(a5)+,d1
	move.w 	d1,(a1)		; no flip, palette 0, no priority
	stop	#$2500		; wait for 1 frame (to make the animation)
	dbf	d0,.print_text
	bra.w	ReadJoypad

SkipTerminator:
	move.w	6(a4),d0		; update d0, skipping the terminator
	bra.s	Continue
	
; Skips directly to first or last relevant slide using the $FFFF terminators
NextSlide:
	cmpa.w	#Slide8+6,a4	; is the boundary limit to avoid going outside the slides being hit?
	bhs.w	WaitNextFrame	; if yes, do nothing
.find_terminator:
	tst.w	(a4)+
	bpl.s	.find_terminator
	bsr.s 	VDP_ClearScreen
	bra.s	UpdateStringProperties
	
PreviousSlide:
	cmpa.w	#Slide0+8,a4	; is the boundary limit to avoid going outside the slides being hit?
	bls.w	WaitNextFrame	; if yes, do nothing
.find_terminator:
	tst.w	-(a4)
	bpl.s	.find_terminator
.find_secondterminator:
	tst.w	-(a4)
	bpl.s	.find_secondterminator
	bsr.s 	VDP_ClearScreen
	bra.s	UpdateStringProperties
	
ClearScreen_Alt:
	bsr.s	VDP_ClearScreen
	bra.w	WaitNextFrame
	
VDP_ClearScreen:
	dmaFillVRAM $00, PLANEA_ADDR, $776, (a0), (a1)
	rts


CPU_CrashSystem:
	jmp	ManualCrash

ROM_End: