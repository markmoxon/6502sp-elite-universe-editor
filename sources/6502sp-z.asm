\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE GAME SOURCE (I/O PROCESSOR)
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

INCLUDE "sources/6502sp-header.h.asm"

CPU 1

CODE% = &2400
LOAD% = &2400
TABLE = &2300

C% = &2400
L% = C%
D% = &D000

Z = 0
XX15 = &90
X1 = XX15
Y1 = XX15+1
X2 = XX15+2
Y2 = XX15+3
SC = XX15+6
SCH = SC+1
OSTP = SC
FF = &FF
OSWRCH = &FFEE
OSBYTE = &FFF4
OSWORD = &FFF1
OSFILE = &FFDD
SCLI = &FFF7
VIA = &FE40
USVIA = VIA
IRQ1V = &204
VSCAN = 57
XX21 = D%
WRCHV = &20E
WORDV = &20C
RDCHV = &210
NVOSWRCH = &FFCB
Tina = &B00
Y = 96
\protlen = 0
PARMAX = 15

\REMparameters expected by RDPARAMS
RED = &F0
WHITE = &FA
WHITE2 = &3F
RED2 = &3
YELLOW2 = &F
MAGNETA2 = &33
CYAN2 = &3C
BLUE2 = &30
GREEN2 = &C
STRIPE = &23

\ ******************************************************************************
\       Name: ZP
\ ******************************************************************************

ORG &80

.ZP

 SKIP 0

.P

 SKIP 1

.Q

 SKIP 1

.R

 SKIP 1

.S

 SKIP 1

.T

 SKIP 1

.SWAP

 SKIP 1

.T1

 SKIP 1

.COL

 SKIP 1

.OSSC

 SKIP 2

\ ******************************************************************************
\       Name: FONT%
\ ******************************************************************************

ORG CODE%

FONT% = P% DIV 256

INCBIN "binaries/P.FONT.bin"

\ ******************************************************************************
\       Name: log
\ ******************************************************************************

.log

IF _MATCH_EXTRACTED_BINARIES
 INCBIN "extracted/workspaces/ICODE-log.bin"
ELSE
 SKIP 1
 FOR I%, 1, 255
   B% = INT(&2000 * LOG(I%) / LOG(2) + 0.5)
   EQUB B% DIV 256
 NEXT
ENDIF

\ ******************************************************************************
\       Name: logL
\ ******************************************************************************

.logL

IF _MATCH_EXTRACTED_BINARIES
 INCBIN "extracted/workspaces/ICODE-logL.bin"
ELSE
 SKIP 1
 FOR I%, 1, 255
   B% = INT(&2000 * LOG(I%) / LOG(2) + 0.5)
   EQUB B% MOD 256
 NEXT
ENDIF

\ ******************************************************************************
\       Name: antilog
\ ******************************************************************************

.antilog

IF _MATCH_EXTRACTED_BINARIES
 INCBIN "extracted/workspaces/ICODE-antilog.bin"
ELSE
 FOR I%, 0, 255
   B% = INT(2^((I% / 2 + 128) / 16) + 0.5) DIV 256
   IF B% = 256
     EQUB B%+1
   ELSE
     EQUB B%
   ENDIF
 NEXT
ENDIF

\ ******************************************************************************
\       Name: antilogODD
\ ******************************************************************************

.antilogODD

IF _MATCH_EXTRACTED_BINARIES
 INCBIN "extracted/workspaces/ICODE-antilogODD.bin"
ELSE
 FOR I%, 0, 255
   B% = INT(2^((I% / 2 + 128.25) / 16) + 0.5) DIV 256
   IF B% = 256
     EQUB B%+1
   ELSE
     EQUB B%
   ENDIF
 NEXT
ENDIF

\ ******************************************************************************
\       Name: ylookup
\ ******************************************************************************

.ylookup

FOR I%, 0, 255
  EQUB &40 + ((I% DIV 8) * 2)
NEXT

\ ******************************************************************************
\       Name: TVT3
\ ******************************************************************************

.TVT3

 EQUD &17243400
 EQUD &47576474
 EQUD &8696A1B1
 EQUD &C6D6E1F1 \View  YRC
 EQUD &17243400
 EQUD &47576474
 EQUD &8696A0B0
 EQUD &C6D6E0F0 \Trade YRW
 EQUD &17243400
 EQUD &47576474
 EQUD &8090A1B1
 EQUD &C0D0E1F1 \Title YWC
 EQUD &17243400
 EQUD &47576474
 EQUD &8292A0B0
 EQUD &C2D2E0F0 \Trade YMW

\.............. Variables - do not alter after PARAMS .................

.XC

 EQUB 1

.YC

 EQUB 1

.K3

 BRK

.U

 BRK

.LINTAB

 BRK

.LINMAX

 BRK

.YSAV

 BRK

.svn

 BRK

.PARANO

 BRK

.DL

 BRK

.VEC

 EQUW 0

.HFX

 BRK

.CATF

 BRK

.K

 EQUD 0

.PARAMS

.ENERGY

 BRK

.ALP1

 BRK

.ALP2

 BRK

.BETA

 BRK

.BET1

 BRK

.DELTA

 BRK

.ALTIT

 BRK

.MCNT

 BRK

.FSH

 BRK

.ASH

 BRK

.QQ14

 BRK

.GNTMP

 BRK

.CABTMP

 BRK

.FLH

 BRK

.ESCP

 BRK


\ ******************************************************************************
\       Name: JMPTAB
\ ******************************************************************************

\ Vectors for OSWRCH - routine should end with JMPPUTBACK once it has had its fill of data

.JMPTAB

\Vector lookup table
 EQUW USOSWRCH
 EQUW BEGINLIN
 EQUW ADDBYT
 EQUW DOFE21 \3
 EQUW DOHFX
 EQUW SETXC \5
 EQUW SETYC \6
 EQUW CLYNS \7
 EQUW RDPARAMS \8-GAME PARAMETERS
 EQUW ADPARAMS \9
 EQUW DODIALS\10
 EQUW DOVIAE\11
 EQUW DOBULB\12
 EQUW DOCATF\13
 EQUW DOCOL \14
 EQUW SETVDU19 \15
 EQUW DOSVN \16
 EQUW DOBRK \17
 EQUW printer
 EQUW prilf

\ ******************************************************************************
\       Name: STARTUP
\ ******************************************************************************

.STARTUP

 LDA RDCHV
 STA newosrdch+1
 LDA RDCHV+1
 STA newosrdch+2
 LDA #(newosrdch MOD256)
 SEI
 STA RDCHV
 LDA #(newosrdch DIV256)
 STA RDCHV+1 \~~
 LDA #&39
 STA VIA+&E
 LDA #&7F
 STA &FE6E
 LDA IRQ1V
 STA VEC
 LDA IRQ1V+1
 STA VEC+1
 LDA #IRQ1 MOD256
 STA IRQ1V
 LDA #IRQ1 DIV256
 STA IRQ1V+1
 LDA #VSCAN
 STA USVIA+5
 CLI

.NOINT

 LDA WORDV
 STA notours+1
 LDA WORDV+1
 STA notours+2
 LDA #NWOSWD MOD256
 SEI
 STA WORDV
 LDA #NWOSWD DIV256
 STA WORDV+1
 CLI
 LDA #FF
 STA COL
 LDA Tina
 CMP #'T'
 BNE PUTBACK
 LDA Tina+1
 CMP #'I'
 BNE PUTBACK
 LDA Tina+2
 CMP #'N'
 BNE PUTBACK
 LDA Tina+3
 CMP #'A'
 BNE PUTBACK
 JSR Tina+4

\ ******************************************************************************
\       Name: PUTBACK
\ ******************************************************************************

\ ............. OSWRCH revectored bumbling .....................

.PUTBACK

 LDA #128

\ ******************************************************************************
\       Name: USOSWRCH
\ ******************************************************************************

.USOSWRCH

 STX SC
 TAX
 BPL OHMYGOD
 ASL A
 TAX
 CPX #39
 BCS OHMYGOD
 LDA JMPTAB,X
 SEI
 STA WRCHV
 LDA JMPTAB+1,X
 STA WRCHV+1
 CLI
 RTS

.OHMYGOD

 LDX SC
 JMP TT26

\ ******************************************************************************
\       Name: DODIALS
\ ******************************************************************************

.DODIALS

 TAX
 LDA #6
 SEI
 STA &FE00
 STX &FE01
 CLI
 JMP PUTBACK\hide dials on death

\ ******************************************************************************
\       Name: DOFE21
\ ******************************************************************************

.DOFE21

 STA &FE21
 JMP PUTBACK \Shimmer on energy bomb

\ ******************************************************************************
\       Name: DOHFX
\ ******************************************************************************

.DOHFX

 STA HFX
 JMP PUTBACK \Hyperspace colours

\ ******************************************************************************
\       Name: DOVIAE
\ ******************************************************************************

.DOVIAE

 STA VIA+&E
 JMP PUTBACK \Keyboard interrupt

\ ******************************************************************************
\       Name: DOCATF
\ ******************************************************************************

.DOCATF

 STA CATF
 JMP PUTBACK

\ ******************************************************************************
\       Name: DOCOL
\ ******************************************************************************

.DOCOL

 STA COL
 JMP PUTBACK

\ ******************************************************************************
\       Name: DOSVN
\ ******************************************************************************

.DOSVN

 STA svn
 JMP PUTBACK

\ ******************************************************************************
\       Name: DOBRK
\ ******************************************************************************

.DOBRK

 BRK
 EQUS "TTEST"
 EQUW 13

\ ******************************************************************************
\       Name: printer
\ ******************************************************************************

.printer

 PHA
 JSR TT26
 PLA
 CMP #11
 BEQ nottosend
 PHA
 LDA #2
 JSR NVOSWRCH
 PLA
 PHA
 CMP #32
 BCS tosend
 CMP #10
 BEQ tosend2
 LDA #13
 JSR POSWRCH
 JMP sent

.tosend2

\CMP#13\BEQsent
 LDA #10
 JSR POSWRCH

.^sent

 LDA #3
 JSR NVOSWRCH
 PLA

.nottosend

 JMP PUTBACK

\ ******************************************************************************
\       Name: POSWRCH
\ ******************************************************************************

.POSWRCH

 PHA
 LDA #1
 JSR NVOSWRCH
 PLA
 JMP NVOSWRCH

\ ******************************************************************************
\       Name: tosend
\ ******************************************************************************

.tosend

 JSR POSWRCH
 JMP sent

\ ******************************************************************************
\       Name: prilf
\ ******************************************************************************

.prilf

 LDA #2
 JSR NVOSWRCH
 LDA #10
 JSR POSWRCH
 JSR POSWRCH
 LDA #3
 JSR NVOSWRCH
 JMP PUTBACK

\ ******************************************************************************
\       Name: DOBULB
\ ******************************************************************************

.DOBULB

 TAX
 BNE ECBLB
 LDA #16*8
 STA SC
 LDA #&7B
 STA SC+1
 LDY #15

.BULL

 LDA SPBT,Y
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL BULL
 JMP PUTBACK

\ ******************************************************************************
\       Name: ECBLB
\ ******************************************************************************

.ECBLB

 LDA #8*14
 STA SC
 LDA #&7A
 STA SC+1
 LDY #15

.BULL2

 LDA ECBT,Y
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL BULL2
 JMP PUTBACK

\ ******************************************************************************
\       Name: SPBT
\ ******************************************************************************

.SPBT

 EQUD &FFAAFFFF
 EQUD &FFFF00FF
 EQUD &FF00FFFF
 EQUD &FFFF55FF

\ ******************************************************************************
\       Name: ECBT
\ ******************************************************************************

.ECBT

 EQUD &FFAAFFFF
 EQUD &FFFFAAFF
 EQUD &FF00FFFF
 EQUD &FFFF00FF

\ ******************************************************************************
\       Name: DOT
\ ******************************************************************************

.DOT

 LDY #2
 LDA (OSSC),Y
 STA X1
 INY
 LDA (OSSC),Y
 STA Y1
 INY
 LDA (OSSC),Y
 STA COL
 CMP #WHITE2
 BNE CPIX2

\ ******************************************************************************
\       Name: CPIX4
\ ******************************************************************************

.CPIX4

 JSR CPIX2
 DEC Y1

\ ******************************************************************************
\       Name: CPIX2
\ ******************************************************************************

.CPIX2

 LDA Y1
\.CPIX
 TAY
 LDA ylookup,Y
 STA SC+1
 LDA X1
 AND #&FC
 ASL A
 STA SC
 BCC P%+5
 INC SC+1
 CLC
 TYA
 AND #7
 TAY
 LDA X1
 AND #2
 TAX
 LDA CTWOS,X
 AND COL
 EOR (SC),Y
 STA (SC),Y
 LDA CTWOS+2,X
 BPL CP1
 LDA SC
 ADC #8
 STA SC
 BCC P%+4
 INC SC+1
 LDA CTWOS+2,X

.CP1

 AND COL
 EOR (SC),Y
 STA (SC),Y
 RTS

\ ******************************************************************************
\       Name: SC48
\ ******************************************************************************

\  ...................... Scanners  ..............................

.SC48

 LDY #4
 LDA (OSSC),Y
 STA COL
 INY
 LDA (OSSC),Y
 STA X1
 INY
 LDA (OSSC),Y
 STA Y1
 JSR CPIX4
 LDA CTWOS+2,X
 AND COL
 STA X1
 STY Q
 LDY #2
 LDA (OSSC),Y
 ASL A
 INY
 LDA (OSSC),Y
 BEQ RTS
 LDY Q
 TAX
 BCC RTS+1

.VLL1

 DEY
 BPL VL1
 LDY #7
 DEC SC+1
 DEC SC+1

.VL1

 LDA X1
 EOR (SC),Y
 STA (SC),Y
 DEX
 BNE VLL1

.RTS

 RTS
 INY
 CPY #8
 BNE VLL2
 LDY #0
 INC SC+1
 INC SC+1

.VLL2

 INY
 CPY #8
 BNE VL2
 LDY #0
 INC SC+1
 INC SC+1

.VL2

 LDA X1
 EOR (SC),Y
 STA (SC),Y
 INX
 BNE VLL2
 RTS

\ ******************************************************************************
\       Name: BRGINLIN   see LL155 in tape
\ ******************************************************************************

\.............Empty Linestore after copying over Tube .........

.BEGINLIN

\was LL155 -CLEAR LINEstr
 STA LINMAX
 LDA #0
 STA LINTAB
 LDA #&82
 JMP USOSWRCH

.^RTS1

 RTS

\ ******************************************************************************
\       Name: ADDBYT
\ ******************************************************************************

.ADDBYT

 INC LINTAB
 LDX LINTAB
 STA TABLE-1,X
 INX
 CPX LINMAX
 BCC RTS1
 LDY #0
 DEC LINMAX
 LDA TABLE+3
 CMP #FF
 BEQ doalaser

.LL27

 LDA TABLE,Y
 STA X1
 LDA TABLE+1,Y
 STA Y1
 LDA TABLE+2,Y
 STA X2
 LDA TABLE+3,Y
 STA Y2
 STY T1
 JSR LOIN
 LDA T1
 CLC
 ADC #4

.Ivedonealaser

 TAY
 CMP LINMAX
 BCC LL27

.DRLR1

 JMP PUTBACK

.doalaser

 LDA COL
 PHA
 LDA #RED
 STA COL
 LDA TABLE+4
 STA X1
 LDA TABLE+5
 STA Y1
 LDA TABLE+6
 STA X2
 LDA TABLE+7
 STA Y2
 JSR LOIN
 PLA
 STA COL
 LDA #8
 BNE Ivedonealaser

\ ******************************************************************************
\       Name: TWOS
\ ******************************************************************************

.TWOS

 EQUD &11224488

\ ******************************************************************************
\       Name: TWOS2
\ ******************************************************************************

.TWOS2

 EQUD &333366CC

\ ******************************************************************************
\       Name: CTWOS
\ ******************************************************************************

.CTWOS

 EQUD &5555AAAA
 EQUW &AAAA

\ ******************************************************************************
\       Name: HLOIN2
\ ******************************************************************************

.HLOIN2

 LDX X1
 STY Y2
 INY
 STY Q
 LDA COL
 JMP HLOIN3 \any colour

\ ******************************************************************************
\       Name: LOIN (Part 1 of 7)
\ ******************************************************************************

.LOIN

 LDA #128
 STA S
 ASL A
 STA SWAP
 LDA X2
 SBC X1
 BCS LI1
 EOR #FF
 ADC #1
 SEC

.LI1

 STA P
 LDA Y2
 SBC Y1
 BEQ HLOIN2
 BCS LI2
 EOR #FF
 ADC #1

.LI2

 STA Q
 CMP P
 BCC STPX
 JMP STPY

\ ******************************************************************************
\       Name: LOIN (Part 2 of 7)
\ ******************************************************************************

.STPX

 LDX X1
 CPX X2
 BCC LI3
 DEC SWAP
 LDA X2
 STA X1
 STX X2
 TAX
 LDA Y2
 LDY Y1
 STA Y1
 STY Y2

.LI3

 LDY Y1
 LDA ylookup,Y
 STA SC+1
 LDA Y1
 AND #7
 TAY
 TXA
 AND #&FC
 ASL A
 STA SC
 BCC P%+4
 INC SC+1
 TXA
 AND #3
 STA R
 LDX Q
 BEQ LIlog7
 LDA logL,X
 LDX P
 SEC
 SBC logL,X
 BMI LIlog4
 LDX Q
 LDA log,X
 LDX P
 SBC log,X
 BCS LIlog5
 TAX
 LDA antilog,X
 JMP LIlog6

.LIlog5

 LDA #FF
 BNE LIlog6

.LIlog7

 LDA #0
 BEQ LIlog6

.LIlog4

 LDX Q
 LDA log,X
 LDX P
 SBC log,X
 BCS LIlog5
 TAX
 LDA antilogODD,X

.LIlog6

 STA Q
 LDX P
 BEQ LIEXS
 INX
 LDA Y2
 CMP Y1
 BCC P%+5
 JMP DOWN

\ ******************************************************************************
\       Name: LOIN (Part 3 of 7)
\ ******************************************************************************

 LDA #&88
 AND COL
 STA LI100+1
 LDA #&44
 AND COL
 STA LI110+1
 LDA #&22
 AND COL
 STA LI120+1
 LDA #&11
 AND COL
 STA LI130+1
 LDA SWAP
 BEQ LI190
 LDA R
 BEQ LI100+6
 CMP #2
 BCC LI110+6
 CLC
 BEQ LI120+6
 BNE LI130+6

.LI190

 DEX
 LDA R
 BEQ LI100
 CMP #2
 BCC LI110
 CLC
 BEQ LI120
 JMP LI130

.LI100

 LDA #&88
 EOR (SC),Y
 STA (SC),Y
 DEX

.LIEXS

 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI110
 CLC
 DEY
 BMI LI101

.LI110

 LDA #&44
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI120
 CLC
 DEY
 BMI LI111

.LI120

 LDA #&22
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI130
 CLC
 DEY
 BMI LI121

.LI130

 LDA #&11
 EOR (SC),Y
 STA (SC),Y
 LDA S
 ADC Q
 STA S
 BCC LI140
 CLC
 DEY
 BMI LI131

.LI140

 DEX
 BEQ LIEX
 LDA SC
 ADC #8
 STA SC
 BCC LI100
 INC SC+1
 CLC
 BCC LI100

.LI101

 DEC SC+1
 DEC SC+1
 LDY #7
 BPL LI110

.LI111

 DEC SC+1
 DEC SC+1
 LDY #7
 BPL LI120

.LI121

 DEC SC+1
 DEC SC+1
 LDY #7
 BPL LI130

.LI131

 DEC SC+1
 DEC SC+1
 LDY #7
 BPL LI140

.LIEX

 RTS

\ ******************************************************************************
\       Name: LOIN (Part 4 of 7)
\ ******************************************************************************

.DOWN

 LDA #&88
 AND COL
 STA LI200+1
 LDA #&44
 AND COL
 STA LI210+1
 LDA #&22
 AND COL
 STA LI220+1
 LDA #&11
 AND COL
 STA LI230+1
 LDA SC
 SBC #&F8
 STA SC
 LDA SC+1
 SBC #0
 STA SC+1
 TYA
 EOR #&F8
 TAY
 LDA SWAP
 BEQ LI191
 LDA R
 BEQ LI200+6
 CMP #2
 BCC LI210+6
 CLC
 BEQ LI220+6
 BNE LI230+6

.LI191

 DEX
 LDA R
 BEQ LI200
 CMP #2
 BCC LI210
 CLC
 BEQ LI220
 BNE LI230

.LI200

 LDA #&88
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI210
 CLC
 INY
 BEQ LI201

.LI210

 LDA #&44
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI220
 CLC
 INY
 BEQ LI211

.LI220

 LDA #&22
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX2
 LDA S
 ADC Q
 STA S
 BCC LI230
 CLC
 INY
 BEQ LI221

.LI230

 LDA #&11
 EOR (SC),Y
 STA (SC),Y
 LDA S
 ADC Q
 STA S
 BCC LI240
 CLC
 INY
 BEQ LI231

.LI240

 DEX
 BEQ LIEX2
 LDA SC
 ADC #8
 STA SC
 BCC LI200
 INC SC+1
 CLC
 BCC LI200

.LI201

 INC SC+1
 INC SC+1
 LDY #&F8
 BNE LI210

.LI211

 INC SC+1
 INC SC+1
 LDY #&F8
 BNE LI220

.LI221

 INC SC+1
 INC SC+1
 LDY #&F8
 BNE LI230

.LI231

 INC SC+1
 INC SC+1
 LDY #&F8
 BNE LI240

.LIEX2

 RTS

\ ******************************************************************************
\       Name: LOIN (Part 5 of 7)
\ ******************************************************************************

.STPY

 LDY Y1
 TYA
 LDX X1
 CPY Y2
 BCS LI15
 DEC SWAP
 LDA X2
 STA X1
 STX X2
 TAX
 LDA Y2
 STA Y1
 STY Y2
 TAY

.LI15

 LDA ylookup,Y
 STA SC+1
 TXA
 AND #&FC
 ASL A
 STA SC
 BCC P%+4
 INC SC+1
 TXA
 AND #3
 TAX
 LDA TWOS,X
 STA R
 LDX P
 BEQ LIfudge
 LDA logL,X
 LDX Q
 SEC
 SBC logL,X
 BMI LIloG
 LDX P
 LDA log,X
 LDX Q
 SBC log,X
 BCS LIlog3
 TAX
 LDA antilog,X
 JMP LIlog2

.LIlog3

 LDA #FF
 BNE LIlog2

.LIloG

 LDX P
 LDA log,X
 LDX Q
 SBC log,X
 BCS LIlog3
 TAX
 LDA antilogODD,X

.LIlog2

 STA P

.LIfudge

 LDX Q
 BEQ LIEX7
 INX
 LDA X2
 SEC
 SBC X1
 BCS P%+6
 JMP LFT

\ ******************************************************************************
\       Name: LOIN (Part 6 of 7)
\ ******************************************************************************

.LIEX7

 RTS
 LDA SWAP
 BEQ LI290
 TYA
 AND #7
 TAY
 BNE P%+5
 JMP LI307+8
 CPY #2
 BCS P%+5
 JMP LI306+8
 CLC
 BNE P%+5
 JMP LI305+8
 CPY #4
 BCS P%+5
 JMP LI304+8
 CLC
 BNE P%+5
 JMP LI303+8
 CPY #6
 BCS P%+5
 JMP LI302+8
 CLC
 BEQ P%+5
 JMP LI300+8
 JMP LI301+8

.LI290

 DEX
 TYA
 AND #7
 TAY
 BNE P%+5
 JMP LI307
 CPY #2
 BCS P%+5
 JMP LI306
 CLC
 BNE P%+5
 JMP LI305
 CPY #4
 BCC LI304S
 CLC
 BEQ LI303S
 CPY #6
 BCC LI302S
 CLC
 BEQ LI301S
 JMP LI300

.LI310

 LSR R
 BCC LI301
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI301
 INC SC+1
 CLC

.LI301S

 BCC LI301

.LI311

 LSR R
 BCC LI302
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI302
 INC SC+1
 CLC

.LI302S

 BCC LI302

.LI312

 LSR R
 BCC LI303
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI303
 INC SC+1
 CLC

.LI303S

 BCC LI303

.LI313

 LSR R
 BCC LI304
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI304
 INC SC+1
 CLC

.LI304S

 BCC LI304

.LIEX3

 RTS

.LI300

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX3
 DEY
 LDA S
 ADC P
 STA S
 BCS LI310

.LI301

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX3
 DEY
 LDA S
 ADC P
 STA S
 BCS LI311

.LI302

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX3
 DEY
 LDA S
 ADC P
 STA S
 BCS LI312

.LI303

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX3
 DEY
 LDA S
 ADC P
 STA S
 BCS LI313

.LI304

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX4
 DEY
 LDA S
 ADC P
 STA S
 BCS LI314

.LI305

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX4
 DEY
 LDA S
 ADC P
 STA S
 BCS LI315

.LI306

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX4
 DEY
 LDA S
 ADC P
 STA S
 BCS LI316

.LI307

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX4
 DEC SC+1
 DEC SC+1
 LDY #7
 LDA S
 ADC P
 STA S
 BCS P%+5
 JMP LI300
 LSR R
 BCS P%+5
 JMP LI300
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCS P%+5
 JMP LI300
 INC SC+1
 CLC
 JMP LI300

.LIEX4

 RTS

.LI314

 LSR R
 BCC LI305
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI305
 INC SC+1
 CLC
 BCC LI305

.LI315

 LSR R
 BCC LI306
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI306
 INC SC+1
 CLC
 BCC LI306

.LI316

 LSR R
 BCC LI307
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI307
 INC SC+1
 CLC
 BCC LI307

\ ******************************************************************************
\       Name: LOIN (Part 7 of 7)
\ ******************************************************************************

.LFT

 LDA SWAP
 BEQ LI291
 TYA
 AND #7
 TAY
 BNE P%+5
 JMP LI407+8
 CPY #2
 BCS P%+5
 JMP LI406+8
 CLC
 BNE P%+5
 JMP LI405+8
 CPY #4
 BCS P%+5
 JMP LI404+8
 CLC
 BNE P%+5
 JMP LI403+8
 CPY #6
 BCS P%+5
 JMP LI402+8
 CLC
 BEQ P%+5
 JMP LI400+8
 JMP LI401+8

.LI291

 DEX
 TYA
 AND #7
 TAY
 BNE P%+5
 JMP LI407
 CPY #2
 BCS P%+5
 JMP LI406
 CLC
 BNE P%+5
 JMP LI405
 CPY #4
 BCC LI404S
 CLC
 BEQ LI403S
 CPY #6
 BCC LI402S
 CLC
 BEQ LI401S
 JMP LI400

.LI410

 ASL R
 BCC LI401
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC

.LI401S

 BCC LI401

.LI411

 ASL R
 BCC LI402
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC

.LI402S

 BCC LI402

.LI412

 ASL R
 BCC LI403
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC

.LI403S

 BCC LI403

.LI413

 ASL R
 BCC LI404
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC

.LI404S

 BCC LI404

.LIEX5

 RTS

.LI400

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX5
 DEY
 LDA S
 ADC P
 STA S
 BCS LI410

.LI401

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX5
 DEY
 LDA S
 ADC P
 STA S
 BCS LI411

.LI402

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX5
 DEY
 LDA S
 ADC P
 STA S
 BCS LI412

.LI403

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX5
 DEY
 LDA S
 ADC P
 STA S
 BCS LI413

.LI404

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX6
 DEY
 LDA S
 ADC P
 STA S
 BCS LI414

.LI405

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX6
 DEY
 LDA S
 ADC P
 STA S
 BCS LI415

.LI406

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX6
 DEY
 LDA S
 ADC P
 STA S
 BCS LI416

.LI407

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX6
 DEC SC+1
 DEC SC+1
 LDY #7
 LDA S
 ADC P
 STA S
 BCS P%+5
 JMP LI400
 ASL R
 BCS P%+5
 JMP LI400
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC
 JMP LI400

.LIEX6

 RTS

.LI414

 ASL R
 BCC LI405
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC
 BCC LI405

.LI415

 ASL R
 BCC LI406
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC
 BCC LI406

.LI416

 ASL R
 BCC LI407
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC
 JMP LI407

\ ******************************************************************************
\       Name: HLOIN
\ ******************************************************************************

.HLOIN

 LDY #0
 LDA (OSSC),Y
 STA Q
 INY
 INY

.HLLO

 LDA (OSSC),Y
 STA X1
 TAX
 INY
 LDA (OSSC),Y
 STA X2
 INY
 LDA (OSSC),Y
 STA Y1
 STY Y2
 AND #3
 TAY
 LDA orange,Y

.^HLOIN3

 STA S
 CPX X2
 BEQ HL6
 BCC HL5
 LDA X2
 STA X1
 STX X2
 TAX

.HL5

 DEC X2
 LDY Y1
 LDA ylookup,Y
 STA SC+1
 TYA
 AND #7
 STA SC
 TXA
 AND #&FC
 ASL A
 TAY
 BCC P%+4
 INC SC+1

.HL1

 TXA
 AND #&FC
 STA T
 LDA X2
 AND #&FC
 SEC
 SBC T
 BEQ HL2
 LSR A
 LSR A
 STA R
 LDA X1
 AND #3
 TAX
 LDA TWFR,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 TYA
 ADC #8
 TAY
 BCS HL7

.HL8

 LDX R
 DEX
 BEQ HL3
 CLC

.HLL1

 LDA S
 EOR (SC),Y
 STA (SC),Y
 TYA
 ADC #8
 TAY
 BCS HL9

.HL10

 DEX
 BNE HLL1

.HL3

 LDA X2
 AND #3
 TAX
 LDA TWFL,X
 AND S
 EOR (SC),Y
 STA (SC),Y

.HL6

 LDY Y2
 INY
 CPY Q
 BEQ P%+5
 JMP HLLO
 RTS

.HL2

 LDA X1
 AND #3
 TAX
 LDA TWFR,X
 STA T
 LDA X2
 AND #3
 TAX
 LDA TWFL,X
 AND T
 AND S
 EOR (SC),Y
 STA (SC),Y
 LDY Y2
 INY
 CPY Q
 BEQ P%+5
 JMP HLLO
 RTS

.HL7

 INC SC+1
 CLC
 JMP HL8

.HL9

 INC SC+1
 CLC
 JMP HL10

\ ******************************************************************************
\       Name: TWFL
\ ******************************************************************************

.TWFL

 EQUD &FFEECC88

\ ******************************************************************************
\       Name: TWFR
\ ******************************************************************************

.TWFR

 EQUD &113377FF

\ ******************************************************************************
\       Name: orange
\ ******************************************************************************

.orange

 EQUB &A5
 EQUB &A5
 EQUB &5A
 EQUB &5A

\ ******************************************************************************
\       Name: PIXEL
\ ******************************************************************************

.PIXEL

 LDY #0
 LDA (OSSC),Y
 STA Q
 INY
 INY

.PXLO

 LDA (OSSC),Y
 STA P
 AND #7
 BEQ PX5
 TAX
 LDA PXCL,X
 STA S
 INY
 LDA (OSSC),Y
 TAX
 INY
 LDA (OSSC),Y
 STY T1
 TAY
 LDA ylookup,Y
 STA SC+1
 TXA
 AND #&FC
 ASL A
 STA SC
 BCC P%+4
 INC SC+1
 TYA
 AND #7
 TAY
 TXA
 AND #3
 TAX
 LDA P
 BMI PX3
 CMP #&50
 BCC PX2
 LDA TWOS2,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 LDY T1
 INY
 CPY Q
 BNE PXLO
 RTS

.PX2

 LDA TWOS2,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL P%+4
 LDY #1
 LDA TWOS2,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 LDY T1
 INY
 CPY Q
 BNE PXLO
 RTS

.PX3

 LDA TWOS,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 LDY T1
 INY
 CPY Q
 BNE PXLO
 RTS

.PX5

 INY
 LDA (OSSC),Y
 TAX
 INY
 LDA (OSSC),Y
 STY T1
 TAY
 LDA ylookup,Y
 STA SC+1
 TXA
 AND #&FC
 ASL A
 STA SC
 BCC P%+4
 INC SC+1
 TYA
 AND #7
 TAY
 TXA
 AND #3
 TAX
 LDA P
 CMP #&50
 BCS PX6
 LDA TWOS2,X
 AND #WHITE
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL P%+4
 LDY #1

.PX6

 LDA TWOS2,X
 AND #WHITE
 EOR (SC),Y
 STA (SC),Y
 LDY T1
 INY
 CPY Q
 BEQ P%+5
 JMP PXLO
 RTS

\ ******************************************************************************
\       Name: PXCL
\ ******************************************************************************

.PXCL

 EQUB WHITE
 EQUB &F
 EQUB &F
 EQUB &F0
 EQUB &F0
 EQUB &A5
 EQUB &A5
 EQUB &F

\ ******************************************************************************
\       Name: newosrdch
\ ******************************************************************************

.newosrdch

 JSR &FFFF
 CMP #128
 BCC P%+6

.badkey

 LDA #7
 CLC
 RTS
 CMP #32
 BCS coolkey
 CMP #13
 BEQ coolkey
 CMP #21
 BNE badkey

.coolkey

 CLC
 RTS

\ ******************************************************************************
\       Name: ADD
\ ******************************************************************************

.ADD

 STA T1
 AND #128
 STA T
 EOR S
 BMI MU8
 LDA R
 CLC
 ADC P
 TAX
 LDA S
 ADC T1
 ORA T
 RTS

.MU8

 LDA S
 AND #127
 STA U
 LDA P
 SEC
 SBC R
 TAX
 LDA T1
 AND #127
 SBC U
 BCS MU9
 STA U
 TXA
 EOR #FF
 ADC #1
 TAX
 LDA #0
 SBC U
 ORA #128

.MU9

 EOR T
 RTS

\ ******************************************************************************
\       Name: HANGER
\ ******************************************************************************

.HANGER

 LDX #2

.HAL1

 STX T
 LDA #130
 STX Q
 JSR DVID4
 LDA P
 CLC
 ADC #Y
 TAY
 LDA ylookup,Y
 STA SC+1
 STA R
 LDA P
 AND #7
 STA SC
 LDY #0
 JSR HAS2
 LDY R
 INY
 STY SC+1
 LDA #&40
 LDY #&F8
 JSR HAS3
 LDY #2
 LDA (OSSC),Y
 TAY
 BEQ HA2
 LDY #0
 LDA #&88
 JSR HAL3
 DEC SC+1
 LDY #&F8
 LDA #&10
 JSR HAS3

.HA2

 LDX T
 INX
 CPX #13
 BCC HAL1
 LDA #60
 STA S
 LDA #&10
 LDX #&40
 STX R

.HAL6

 LDX R
 STX SC+1
 STA T
 AND #&FC
 STA SC
 LDX #&88
 LDY #1

.HAL7

 TXA
 AND (SC),Y
 BNE HA6
 TXA
 AND #RED
 ORA (SC),Y
 STA (SC),Y
 INY
 CPY #8
 BNE HAL7
 INC SC+1
 INC SC+1
 LDY #0
 BEQ HAL7

.HA6

 LDA T
 CLC
 ADC #16
 BCC P%+4
 INC R
 DEC S
 BNE HAL6

.HA3

 RTS

.HAS2

 LDA #&22

.HAL2

 TAX
 AND (SC),Y
 BNE HA3
 TXA
 AND #RED
 ORA (SC),Y
 STA (SC),Y
 TXA
 LSR A
 BCC HAL2
 TYA
 ADC #7
 TAY
 LDA #&88
 BCC HAL2
 INC SC+1

.HAL3

 TAX
 AND (SC),Y
 BNE HA3
 TXA
 AND #RED
 ORA (SC),Y
 STA (SC),Y
 TXA
 LSR A
 BCC HAL3
 TYA
 ADC #7
 TAY
 LDA #&88
 BCC HAL3
 RTS

.HAS3

 TAX
 AND (SC),Y
 BNE HA3
 TXA
 ORA (SC),Y
 STA (SC),Y
 TXA
 ASL A
 BCC HAS3
 TYA
 SBC #8
 TAY
 LDA #&10
 BCS HAS3
 RTS

\ ******************************************************************************
\       Name: DVID4
\ ******************************************************************************

.DVID4

 LDX #8
 ASL A
 STA P
 LDA #0

.DVL4

 ROL A
 BCS DV8
 CMP Q
 BCC DV5

.DV8

 SBC Q

.DV5

 ROL P
 DEX
 BNE DVL4
 RTS

\ ******************************************************************************
\       Name: ADPARAMS
\ ******************************************************************************

.ADPARAMS

 INC PARANO
 LDX PARANO
 STA PARAMS-1,X
 CPX #PARMAX
 BCS P%+3
 RTS
 JSR DIALS
 JMP PUTBACK

\ ******************************************************************************
\       Name: RDPARAMS
\ ******************************************************************************

.RDPARAMS

 LDA #0
 STA PARANO
 LDA #&89
 JMP USOSWRCH

\ ******************************************************************************
\       Name: DKS4
\ ******************************************************************************

MACRO DKS4
 LDX #3
 SEI
 STX &FE40
 LDX #&7F
 STX &FE43
 STA &FE4F
 LDA &FE4F
 LDX #&B
 STX &FE40
 CLI
ENDMACRO

\ ******************************************************************************
\       Name: KYTB
\ ******************************************************************************

.KYTB

 EQUB 0
 EQUB &E8
 EQUB &E2
 EQUB &E6
 EQUB &E7
 EQUB &C2
 EQUB &D1
 EQUB &C1
 EQUD &35237060
 EQUW &2265
 EQUB &45
 EQUB &52 \? <>XSA.FBRLtabescTUMEJC
 NOP

\ ******************************************************************************
\       Name: KEYBOARD
\ ******************************************************************************

.KEYBOARD

 LDY #9

.DKL2

 LDA KYTB-2,Y
 DKS4
 ASL A
 LDA #0
 ADC #FF
 EOR #FF
 STA (OSSC),Y
 DEY
 CPY #2
 BNE DKL2 \-ve INKEY
 LDA #16
 SED

.DKL3

 DKS4
 TAX
 BMI DK1
 CLC
 ADC #1
 BPL DKL3

.DK1

 CLD
 EOR #128
 STA (OSSC),Y
 LDX #1
 LDA #&80
 JSR OSBYTE
 TYA
 LDY #10
 STA (OSSC),Y
 LDX #2
 LDA #&80
 JSR OSBYTE
 TYA
 LDY #11
 STA (OSSC),Y
 LDX #3
 LDA #&80
 JSR OSBYTE
 TYA
 LDY #12
 STA (OSSC),Y
 LDY #14
 LDA &FE40
 STA (OSSC),Y

.DK2

 RTS

\ ******************************************************************************
\       Name: OSWVECS
\ ******************************************************************************

\ ......... Revectoring of OSWORD ...............................

.OSWVECS

 EQUW KEYBOARD
 EQUW PIXEL
 EQUW MSBAR
 EQUW WSCAN
 EQUW SC48
 EQUW DOT
 EQUW DODKS4
 EQUW HLOIN
 EQUW HANGER
 EQUW SOMEPROT
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE

\ Above vector lookup table is JSRed below, after registers are preserved.
\ OSSC points to the parameter block, and should not be corrupted.
\ Copy into SC if it may be corrupted.  End with an RTS

\ ******************************************************************************
\       Name: NWOSWD
\ ******************************************************************************

.NWOSWD

 BIT svn
 BMI notours
 CMP #240
 BCC notours
 STX OSSC
 STY OSSC+1
 PHA
 SBC #240
 ASL A
 TAX
 LDA OSWVECS,X
 STA JSRV+1
 LDA OSWVECS+1,X
 STA JSRV+2
 LDX OSSC

.JSRV

 JSR &FFFC \Poked over
 PLA
 LDX OSSC
 LDY OSSC+1

.^SAFE

 RTS

\ ******************************************************************************
\       Name: notours
\ ******************************************************************************

.notours

 JMP &FFFC \~~

\ ******************************************************************************
\       Name: MSBAR
\ ******************************************************************************

.MSBAR

 LDY #2
 LDA (OSSC),Y
 ASL A
 ASL A
 ASL A
 ASL A
 STA T
 LDA #97
 SBC T
 STA SC
 LDA #&7C
 STA SCH
 LDY #3
 LDA (OSSC),Y
 LDY #5

.MBL1

 STA (SC),Y
 DEY
 BNE MBL1
 PHA
 LDA SC
 CLC
 ADC #8
 STA SC
 PLA
 AND #&AA
 LDY #5

.MBL2

 STA (SC),Y
 DEY
 BNE MBL2
 RTS

\ ******************************************************************************
\       Name: WSCAN
\ ******************************************************************************

.WSCAN

 LDA #0
 STA DL

.WSCAN1

 LDA DL
 BEQ WSCAN1
 RTS

\ ******************************************************************************
\       Name: DODKS4
\ ******************************************************************************

.DODKS4

 LDY #2
 LDA (OSSC),Y
 DKS4
 STA (OSSC),Y
 RTS

\ ******************************************************************************
\       Name: cls
\ ******************************************************************************

\ ............. Character Print .....................

.cls

 JSR TTX66
 JMP RR4

\ ******************************************************************************
\       Name: TT67
\ ******************************************************************************

.TT67

 LDA #12

\ ******************************************************************************
\       Name: TT26
\ ******************************************************************************

.TT26

 STA K3
 TYA
 PHA
 TXA
 PHA
 LDA K3
 TAY
 BEQ RR4S
 CMP #11
 BEQ cls
 CMP #7
 BNE P%+5
 JMP R5
 CMP #32
 BCS RR1
 CMP #10
 BEQ RRX1
 LDX #1
 STX XC

.RRX1

 CMP #13
 BEQ RR4S
 INC YC

.RR4S

 JMP RR4

.RR1

 TAY
\BEQRR4
 BPL P%+5
 JMP RR4
 LDX #(FONT%-1)
 ASL A
 ASL A
 BCC P%+4
 LDX #(FONT%+1)
 ASL A
 BCC P%+3
 INX
 STA Q
 STX R
 LDA XC
 LDX CATF
 BEQ RR5
 CPY #32
 BNE RR5
 CMP #17
 BEQ RR4

.RR5

 ASL A
 ASL A
 ASL A
 STA SC
 LDA YC
 CPY #&7F
 BNE RR2
 DEC XC
 ASL A
 ASL SC
 ADC #&3F
 TAX
 LDY #&F0
 JSR ZES2
 BEQ RR4

.RR2

 INC XC
 CMP #24
 BCC RR3
 PHA
 JSR TTX66
 LDA #1
 STA XC
 STA YC
 PLA
 LDA K3
 JMP RR4

.RR3

 ASL A
 ASL SC
 ADC #&40

.RREN

 STA SC+1
 LDA SC
 CLC
 ADC #8
 STA S
 LDA SC+1
 STA T
 LDY #7

.RRL1

 LDA (Q),Y
 AND #&F0
 STA U
 LSR A
 LSR A
 LSR A
 LSR A
 ORA U
 AND COL
 EOR (SC),Y
 STA (SC),Y
 LDA (Q),Y
 AND #&F
 STA U
 ASL A
 ASL A
 ASL A
 ASL A
 ORA U
 AND COL
 EOR (S),Y
 STA (S),Y
 DEY
 BPL RRL1

.^RR4

 PLA
 TAX
 PLA
 TAY
 LDA K3

.rT9

 RTS

.R5

 LDX #(BELI MOD256)
 LDY #(BELI DIV256)
 JSR OSWORD
 JMP RR4

.BELI

 EQUW &12
 EQUW &FFF1
 EQUW 200
 EQUW 2

\ ******************************************************************************
\       Name: TTX66
\ ******************************************************************************

.TTX66

 LDX #&40

.BOL1

 JSR ZES1
 INX
 CPX #&70
 BNE BOL1

.BOX

 LDA #&F
 STA COL
 LDY #1
 STY YC
 LDY #11
 STY XC
 LDX #0
 STX X1
 STX Y1
 STX Y2
\STXQQ17
 DEX
 STX X2
 JSR LOIN
 LDA #2
 STA X1
 STA X2
 JSR BOS2

.BOS2

 JSR BOS1

.BOS1

 LDA #0
 STA Y1
 LDA #2*Y-1
 STA Y2
 DEC X1
 DEC X2
 JSR LOIN
 LDA #&F
 STA &4000
 STA &41F8
 RTS

\ ******************************************************************************
\       Name: ZES1
\ ******************************************************************************

.ZES1

 LDY #0
 STY SC

\ ******************************************************************************
\       Name: ZES2
\ ******************************************************************************

.ZES2

 LDA #0
 STX SC+1

.ZEL1

 STA (SC),Y
 INY
 BNE ZEL1
 RTS

\ ******************************************************************************
\       Name: SETXC
\ ******************************************************************************

.SETXC

 STA XC
 JMP PUTBACK

\ ******************************************************************************
\       Name: SETYC
\ ******************************************************************************

.SETYC

 STA YC
 JMP PUTBACK

\ ******************************************************************************
\       Name: SOMEPROT
\ ******************************************************************************

.SOMEPROT

 LDY #2

.SMEPRTL

 LDA do65C02-2,Y
 STA (OSSC),Y
 INY
 CPY #protlen+2
 BCC SMEPRTL
 RTS

\ ******************************************************************************
\       Name: CLYNS
\ ******************************************************************************

.CLYNS

 LDA #20
 STA YC
 LDA #&6A
 STA SC+1
 JSR TT67
 LDA #0
 STA SC
 LDX #3

.CLYL

 LDY #8

.EE2

 STA (SC),Y
 INY
 BNE EE2
 INC SC+1
 STA (SC),Y
 LDY #&F7

.EE3

 STA (SC),Y
 DEY
 BNE EE3
 INC SC+1
 DEX
 BNE CLYL
\INX\STXSC
 JMP PUTBACK

\ ******************************************************************************
\       Name: DIALS (Part 1 of 4)
\ ******************************************************************************

.DIALS

 LDA #1
 STA VIA+&E
 LDA #&A0
 STA SC
 LDA #&71
 STA SC+1
 JSR PZW2
 STX K+1
 STA K
 LDA #14
 STA T1
 LDA DELTA
\LSRA
 JSR DIL-1

\ ******************************************************************************
\       Name: DIALS (Part 2 of 4)
\ ******************************************************************************

 LDA #0
 STA R
 STA P
 LDA #8
 STA S
 LDA ALP1
 LSR A
 LSR A
 ORA ALP2
 EOR #128
 JSR ADD
 JSR DIL2
 LDA BETA
 LDX BET1
 BEQ P%+4
 SBC #1
 JSR ADD
 JSR DIL2

\ ******************************************************************************
\       Name: DIALS (Part 3 of 4)
\ ******************************************************************************

\LDAMCNT
\AND#3
\BEQP%+3
\RTS
 LDY #0
 JSR PZW
 STX K
 STA K+1
 LDX #3
 STX T1

.DLL23

 STY XX15,X
 DEX
 BPL DLL23
 LDX #3
 LDA ENERGY
 LSR A
 LSR A
 STA Q

.DLL24

 SEC
 SBC #16
 BCC DLL26
 STA Q
 LDA #16
 STA XX15,X
 LDA Q
 DEX
 BPL DLL24
 BMI DLL9

.DLL26

 LDA Q
 STA XX15,X

.DLL9

 LDA XX15,Y
 STY P
 JSR DIL
 LDY P
 INY
 CPY #4
 BNE DLL9

\ ******************************************************************************
\       Name: DIALS (Part 4 of 4)
\ ******************************************************************************

 LDA #&70
 STA SC+1
 LDA #&20
 STA SC
 LDA FSH
 JSR DILX
 LDA ASH
 JSR DILX
 LDA #YELLOW2
 STA K
 STA K+1
 LDA QQ14
 JSR DILX+2
 JSR PZW2
 STX K+1
 STA K
 LDX #11
 STX T1
 LDA CABTMP
 JSR DILX
 LDA GNTMP
 JSR DILX
 LDA #&F0
 STA T1
 LDA #YELLOW2
 STA K
 STA K+1
 LDA ALTIT
 JMP DILX

\ ******************************************************************************
\       Name: PZW2
\ ******************************************************************************

.PZW2

 LDX #WHITE2
 EQUB &2C

\ ******************************************************************************
\       Name: PZW
\ ******************************************************************************

.PZW

 LDX #STRIPE
 LDA MCNT
 AND #8
 AND FLH
 BEQ P%+5
 LDA #GREEN2
 RTS
 LDA #RED2
 RTS

\ ******************************************************************************
\       Name: DILX
\ ******************************************************************************

.DILX

 LSR A
 LSR A
 LSR A
 LSR A

.^DIL

 STA Q
 LDX #FF
 STX R
 CMP T1
 BCS DL30
 LDA K+1
 BNE DL31

.DL30

 LDA K

.DL31

 STA COL
 LDY #2
 LDX #7

.DL1

 LDA Q
 CMP #2
 BCC DL2
 SBC #2
 STA Q
 LDA R

.DL5

 AND COL
 STA (SC),Y
 INY
 STA (SC),Y
 INY
 STA (SC),Y
 TYA
 CLC
 ADC #6
 TAY
 DEX
 BMI DL6
 BPL DL1

.DL2

 EOR #1
 STA Q
 LDA R

.DL3

 ASL A
 AND #&AA
 DEC Q
 BPL DL3
 PHA
 LDA #0
 STA R
 LDA #99
 STA Q
 PLA
 JMP DL5

.DL6

 INC SC+1
 INC SC+1

.DL9

 RTS

\ ******************************************************************************
\       Name: DIL2
\ ******************************************************************************

.DIL2

 LDY #1
 STA Q

.DLL10

 SEC
 LDA Q
 SBC #2
 BCS DLL11
 LDA #FF
 LDX Q
 STA Q
 LDA CTWOS,X
 AND #WHITE2
 BNE DLL12

.DLL11

 STA Q
 LDA #0

.DLL12

 STA (SC),Y
 INY
 STA (SC),Y
 INY
 STA (SC),Y
 INY
 STA (SC),Y
 TYA
 CLC
 ADC #5
 TAY
 CPY #60
 BCC DLL10
 INC SC+1
 INC SC+1
 RTS

\ ******************************************************************************
\       Name: TVT1
\ ******************************************************************************

.TVT1

 EQUD &16254334
 EQUD &52617086
 EQUD &96A5B4C3
 EQUD &D2E1F007 \Dials

\ ******************************************************************************
\       Name: do65C02, whiz
\ ******************************************************************************

.do65C02

.whiz

 LDA (0)
 PHA
 LDA (2)
 STA (0)
 PLA
 STA (2)
\NOP\NOP\NOP\NOP
 INC 0
 BNE P%+4
 INC 1
 LDA 2
 BNE P%+4
 DEC 3
 DEC 2 \SC = 2
 DEA
 CMP 0
 LDA 3
 SBC 1
 BCS whiz
 JMP (0,X)
.end65C02

\**
protlen = end65C02-do65C02

\ ******************************************************************************
\       Name: IRQ1
\ ******************************************************************************

.IRQ1

 TYA
 PHA
 LDY #15
 LDA #2
 BIT VIA+&D
 BNE LINSCN
 BVC jvec
 LDA #&14
 STA &FE20
 LDA ESCP
 AND #4
 EOR #&34
 STA &FE21\ESCP

.VNT2

 LDA TVT1,Y
 STA &FE21
 DEY
 BNE VNT2

.jvec

 PLA
 TAY
 JMP (VEC)

.LINSCN

 LDA #30
 STA DL
 STA USVIA+4
 LDA #VSCAN
 STA USVIA+5
 LDA HFX
 BNE jvec
 LDA #&18
 STA &FE20

.^VNT3

 LDA TVT3,Y
 STA &FE21
 DEY
 BNE VNT3
\LDAsvn
\BMIjvec
 PLA
 TAY
 LDA &FE41
 LDA &FC
 RTI

\ ******************************************************************************
\       Name: SETVDU19
\ ******************************************************************************

.SETVDU19

 STA VNT3+1
 JMP PUTBACK

\ ******************************************************************************
\
\ Save output/I.CODE.bin
\
\ ******************************************************************************

PRINT "I.CODE"
PRINT "Assembled at ", ~CODE%
PRINT "Ends at ", ~P%
PRINT "Code size is ", ~(P% - CODE%)
PRINT "Execute at ", ~LOAD%
PRINT "Reload at ", ~LOAD%
PRINT "protlen = ", ~protlen

PRINT "S.I.CODE ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/I.CODE.bin", CODE%, P%, LOAD%

\INPUT"Insert destination disk and hit RETURN"A$
\OSCLI("S.I.CODE "+STR$~W%+" "+STR$~O%+" FFFF"+STR$~STARTUP+" FFFF"+STR$~H%)
\PRINT"CODE:";~C%",";~P%" (";&4000-P%" Free)  ZP:";~ZP;"Prot: ";~protlen
