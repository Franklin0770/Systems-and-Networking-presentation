; ---------------------------------------------------------------------------
; Macros to define text based on VRAM tiles
; ---------------------------------------------------------------------------

chars function c1,c2,((c1-$20)<<16)|(c2-$20)
char function c,(c-$20)

dfntxt: macro string
i	set	0
	while i < strlen(string)
	dc.b	(substr(string, i, 1) - $20)
i	set i + 1
	endm
	endm

; ---------------------------------------------------------------------------
; Macros to set VDP memory addresses, spaces and to build DMA commands
; ---------------------------------------------------------------------------

vdpCommand function address,type,((address&$3FFF)<<16)|((address&$C000)>>14)|(type)

setRAMAddress: macro address, type, VDPControlPort
	move.l  #vdpCommand(address,type),VDPControlPort
	endm

vdpSetVideoAddress: macro address, VDPControlPort
    setRAMAddress	address, VRAM, VDPControlPort
	endm
	
vdpSetColorAddress: macro address, VDPControlPort
	setRAMAddress	address, CRAM, VDPControlPort
	endm

vdpSetVerticalScrollAddress: macro address, VDPControlPort
    setRAMAddress	address, VSRAM, VDPControlPort
	endm


vdpSetVideoSpace: macro offset, VDPControlPort
    move.l  #(((offset*32)&$3FFF)<<16)|(((offset*32)&$C000)>>14)|(VRAM),VDPControlPort
	endm
	
vdpSetColorSpace: macro offset, VDPControlPort
	move.l  #(((offset*2)&$3FFF)<<16)|(((offset*2)&$C000)>>14)|(CRAM),VDPControlPort
	endm

dmaCommand function address,type,((address&$3FFF)<<16)|((address&$C000)>>14)|(type|$80)
dmaSource function address,((address>>1)&$7FFFFF)
dmaLength function length,((length>>1)&$7FFF)
dmaCommandLength function length,((VDPREG_DMALEN_H|((length&$FF00)>>8))<<16)|($9300|(length&$FF))
dmaCommandSrcLow function source,((VDPREG_DMASRC_M|((source&$FF00)>>8))<<16)|($9500|(source&$FF))
dmaCommandSrcHigh function source,VDPREG_DMASRC_H|(((source&$FF0000)>>16)&$7F)

; Tells the VDP to copy a region of 68k memory to VRAM or CRAM or VSRAM.
dma68kToVDP macro src, dest, length, type, bswap, VDPControlPort
	if MOMPASS>1
		if ((src)&1)<>0
			fatal "DMA is transferring from odd source $\{src}! This will transfer the wrong data, because the VDP ignores the low bit of source address. Please align the data to an even address."
		endif
		if ((dest)&1)<>0
			if ~~(type==VRAM)
				fatal "DMA is transferring to odd destination $\{dest}! This is ignored on real hardware for CRAM and VSRAM, and may behave inconsistently on emulators. Please ensure that you transfer to even destinations only."
			else
				fatal "DMA is transferring to odd destination $\{dest}! This will byte-swap the data copied. If you want to do this, then set the last parameter of the macro to 1 instead."
			endif
		endif
		if ((length)&1)<>0
			fatal "DMA is transferring an odd number of bytes $\{length}! DMA can only transfer an even number of bytes."
		endif
		if (length)==0
			fatal "DMA is transferring 0 bytes (becomes a 128kB transfer). If you really mean it, pass 128kB (131072) instead."
		endif
		if (((src)+(length)-1)>>17)<>((src)>>17)
			fatal "DMA crosses a 128kB boundary. You should either split the DMA manually or align the source adequately."
		endif
	endif
	if ~~(bswap)
		set	.c,0
	else
		if ~~(type==VRAM)
			fatal "Only VRAM supports byte-swap on DMA."
		endif
		set	.c,1
	endif
	move.l	#dmaCommandLength(dmaLength(length)),VDPControlPort
	move.l	#dmaCommandSrcLow(dmaSource(src)),VDPControlPort
	move.l	#(dmaCommandSrcHigh(dmaSource(src))<<16)|((dmaCommand((dest)|.c,type)>>16)&$FFFF),VDPControlPort
	move.w	#(dmaCommand((dest)|.c,type)&$FFFF),VDPControlPort
    endm

; Tells the VDP to fill a region of VRAM with a certain byte.
; VRAM fill works like this: the write to the data port happens as normal; that is: 
; * the high byte is written to address^1
; * the low byte is written to address
; Then, the remainder of the fill goes like:
; * the address is incremented by the autoincrement register value
; * high byte of word written to data port is written to address^1
; * repeat until done
; For an even target address, this means:
; * the high byte is written to address+1
; * the low byte is written to address
; * the high byte is written to address (overwrites previous write)
; * the high byte is written to address+3
; * the high byte is written to address+2
; * etc.
; For an odd target address, this means:
; * the high byte is written to address
; * the low byte is written to address+1
; * the high byte is written to address+3
; * the high byte is written to address+2
; * etc.
; This allows reducing the length of the fill by 1.
; It is possible to fill to CRAM and to VSRAM, but it is buggy,
; and not emulated in most emulators.

dmaFillVRAM macro byte, address, length, VDPControlPort, VDPDataPort
	if MOMPASS>1
		if ((address)&1)<>0
			fatal "DMA is filling an odd destination $\{address}! This will cause a spurious write to the address immediately before. Please ensure you fill starting at even addresses only."
		endif
		if (length)==0
			fatal "DMA is filling 0 bytes (becomes a 64kB fill). If you really mean it, pass 64kB (65536) instead."
		endif
	endif
	
	move.l	#dmaCommandLength(2*(length-2)),VDPControlPort
	move.l	#(VDPREG_INCR|1)<<16|(VDPREG_DMASRC_H|$80),VDPControlPort ; VRAM pointer increment: $0001, VRAM fill
	; Forcing the low bit of address to be 1, as described before.
	move.l	#dmaCommand((address)|1,VRAM),VDPControlPort
	move.w	#((byte)<<8)|(byte),VDPDataPort
.wait:
	move.w	(a0),d2
	btst	#1,d2
	bne.s	.wait	; busy loop until the VDP is finished filling
	move.w	#(VDPREG_INCR)|2,(a0) ; VRAM pointer increment back to 2
    endm
	
; Tells the VDP to copy from a region of VRAM to another.
dmaCopyVRAM macro src, dest, length, VDPControlPort
	if MOMPASS>1
		if (length)==0
			fatal "DMA is copying 0 bytes (becomes a 64kB copy). If you really mean it, pass 64kB (65536) instead."
		endif
	endif
	move.l	#dmaCommandLength(length),VDPControlPort
	move.l	#dmaCommandSrcLow(src),VDPControlPort
	move.l	#(VDPREG_INCR|1)<<16|(VDPREG_DMASRC_H|$C0),VDPControlPort ; VRAM pointer increment: $0001, VRAM copy
	move.l	#dmaCommand(dest,VRAM),VDPControlPort
    endm

	
vdpCoordinates function x,y,vdpCommand((PLANEA_ADDR)|(y*($40*2)+x*2),VRAM)

	
VRAMCoordinates: macro x, y
address set (PLANEA_ADDR)|(y*($40*2)+x*2)
	dc.l	((address&$3FFF)<<16)|((address&$C000)>>14)|(VRAM)
	endm

; ---------------------------------------------------------------------------
; More efficient instructions
; ---------------------------------------------------------------------------

addaq: macro value,register
	if (value > $7FFF)
		fatal "operand must be in range 1..$7FFF"
	endif
	lea value(register),register
	endm
	
subaq: macro value,register
	if (value > $7FFF)
		fatal "operand must be in range 1..$7FFF"
	endif
	lea -value(register),register
	endm