; VGASYNC - Force VGA sync polarities negative
; Copyright 1991, John B. Thiel, all rights reserved.
;
; Copyright abandoned, released to public domain - March, 1992
; by John B. Thiel (jbthiel@cse.ogi.edu)
;
;
;
; NAME
;    vgasync - Keep VGA sync polarities negative
;
; SYNOPSIS
;    detach vgasync
;
; DESCRIPTION
;    'vgasync' runs as a background process under OS/2 and periodically
; (re)sets the horizontal and vertical sync polarities of an (S)VGA card to
; negative sync.
;
;    Many (all?) SVGA cards change the polarities of the H and V sync
; signals to indicate to an assumed multisync monitor the current video mode
; (and implied scan frequencies). 'vgasync' allows older fixed-frequency
; monitors that require a fixed sync polarity to be used with such SVGA
; cards without requiring hardware modification of the sync signals.  With
; the addition of manual sync controls on the monitor and/or a means (eg.
; software drivers) of tweaking the VGA CRT control registers, a "fixed
; frequency" monitor can then display most of the SVGA extended video modes.
;
;    This program requires IOPL to run.
;
;
; $Log$
;
;
;
; Note: to effect transition to an IOPL segment -
;
; In the .def, the IOPL segments must NOT be "conforming". A conforming
; segment executes at the privilege level of the caller, which is precisely
; what we don't want when trying to allow a normal application (PL3) to
; execute IO (PL2).
;
; The transition to the IO segment must be effected via a "call" to
; effect the privilege transition through a call gate. A far jump will
; not work (general protection trap).
;
;


INCLUDELIB doscalls.lib


INCLUDE os2.inc


.286
.MODEL small

.DATA

delay	dd	1000		; milliseconds delay

.CODE

start:

	call	far ptr setsync	; call gate needed for PL transition



IOSEG SEGMENT WORD PUBLIC 'CODE'
ASSUME CS:IOSEG


setsync:

	mov	DX, 03cch	;read VGA's Misc. Output Reg.
	cli
	in	AL, DX
	or	AL, 0c0h	;force negative VSYNC and HSYNC
	mov	DX, 03c2h
	out	DX, AL
	sti

	@DosSleep [delay]
	jmp	setsync



IOSEG ENDS


END start			; entry point is start
