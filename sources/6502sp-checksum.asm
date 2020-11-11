\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE ENCRYPTION SOURCE
\
\ 6502 Second Processor Elite was written by Ian Bell and David Braben and is
\ copyright Acornsoft 1985
\
\ The code on this site is identical to the version released on Ian Bell's
\ personal website at http://www.elitehomepage.org/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ ******************************************************************************

\ The following routines from the S.PCODES BBC BASIC source file are implemented
\ in the 6502sp-checksum.py script - this file is purely for reference and is
\ not used in the build process

\ ZP: This sets the checksum byte at S%-1

.ZP

 SEC

 LDY #0                 \ Set Y = 0

 STY ZP                 \ Set ZP = 0

 LDX #&10               \ Set X = &10, so we start with (X Y) = &1000

 TXA                    \ Set A = &10

.CHKL

 STX ZP+1               \ Set ZP(1 0) = (X 0)

 STY ZP+3               \ Set ZP+3 = Y

 ADC (ZP),Y             \ A = A + C + contents of (X Y)
 EOR ZP+3               \ A = A EOR Y
 SBC ZP+1               \ A = A - (1 - C) - X

 DEY                    \ Loop through whole page X
 BNE CHKL

 INX                    \ Loop to next page until X = &A0 (i.e. &A000)
 CPX #&A0
 BCC CHKL

 STA S%-1               \ Store A in checksum byte at S%-1

 RTS                    \ Return from the subroutine



\ SC: This EORs bytes between &1300 and &9FFF

.SC

 LDY #0                 \ (X Y) = SC(1 0) = &1300
 STY SC
 LDX #&13

.DEEL

 STX SC+1

 TYA                    \ ?(X Y) = ?(X Y) EOR Y EOR &75
 EOR (SC),Y
 EOR #&75
 STA (SC),Y

 DEY                    \ Loop through page
 BNE DEEL

 INX                    \ Next page until (X Y) = &A000
 CPX #&A0
 BNE DEEL               \ Loop back if X < &A0

 RTS                    \ Return from the subroutine



\ V: This reverses the order of bytes between G% and F%-1

.V

 LDA #G%MOD256          \ V(1 0) = G%

.SC

 STA V
 LDA #G%DIV256
 STA V+1

 LDA #(F%-1)MOD256      \ SC(1 0) = F%-1
 STA SC
 LDA #(F%-1)DIV256
 STA SC+1

.whiz

 LDA (V)                \ Stack = ?V
 PHA

 LDA (SC)               \ ?V = ?SC
 STA (V)

 PLA
 STA (SC)               \ ?SC = stack

 INC V                  \ Increment V(1 0)
 BNE P%+4
 INC V+1

 LDA SC                 \ Decrement SC(1 0)
 BNE P%+4
 DEC SC+1
 DEC SC

 DEA                    \ Loop back while SC(1 0) > V(1 0)
 CMP V
 LDA SC+1
 SBC V+1
 BCS whiz

 RTS                    \ Return from the subroutine
