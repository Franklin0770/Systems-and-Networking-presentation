; Taken from the Sonic Retro's Sonic 1 disassembly on GitHub (unused)
	
	padding off		; We don't want AS padding out dc.b instructions
	listing purecode; We sure want the listing file, but only the final code in expanded macros
	page	0		; Don't want form feeds
	
notZ80 function cpu,(cpu<>128)&&(cpu<>32988) ; define notZ80 function

; make org safer (impossible to overwrite previously assembled bytes)
; and also make it work in Z80 code without creating a new segment
org macro address
	if notZ80(MOMCPU)
		if address < *
			error "too much stuff before org $\{address} ($\{(*-address)} bytes)"
		else
			!org address
		endif
	else
		if address < $
			error "too much stuff before org 0\{address}h (0\{($-address)}h bytes)"
		else
			while address > $
				db 0
			endm
		endif
	endif
    endm

; define an alternate org that fills the extra space with 0s instead of FFs
org0 macro address
.diff := address - *
	if .diff < 0
		error "too much stuff before org0 $\{address} ($\{(-diff)} bytes)"
	else
		while .diff > 1024
			; AS can only generate 1 kb of code on a single line
			dc.b [1024]0
.diff := .diff - 1024
		endm
		dc.b [.diff]0
	endif
    endm