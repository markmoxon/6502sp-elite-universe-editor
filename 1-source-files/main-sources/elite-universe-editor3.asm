\ ******************************************************************************
\
\ ELITE UNIVERSE EDITOR (PART 3)
\
\ The Universe Editor is an extended version of BBC Micro Elite by Mark Moxon
\
\ The original 6502 Second Processor Elite was written by Ian Bell and David
\ Braben and is copyright Acornsoft 1985
\
\ The original BBC Master Elite was written by Ian Bell and David Braben and is
\ copyright Acornsoft 1986
\
\ The extra code in the Universe Editor is copyright Mark Moxon
\
\ The code on this site is identical to the source discs released on Ian Bell's
\ personal website at http://www.elitehomepage.org/ (it's just been reformatted
\ to be more readable)
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ******************************************************************************

\ This part must be within main memory on the BBC Master, so that disc errors
\ can be processed properly

\ ******************************************************************************
\
\       Name: SaveLoadFile
\       Type: Subroutine
\   Category: Universe editor
\    Summary: Save or load a universe file
\
\ ------------------------------------------------------------------------------
\
\ The filename should be stored at INWK, terminated with a carriage return (13).
\ The routine asks for a drive number and updates the filename accordingly
\ before performing the load or save.
\
\ Arguments:
\
\   A                   File operation to be performed. Can be one of the
\                       following:
\
\                         * 0 (save file)
\
\                         * &FF (load file)
\
\ Returns:
\
\   C flag              Set if an invalid drive number was entered
\
\ ******************************************************************************

.SaveLoadFile

 PHA                    \ Store A on the stack so we can restore it after the
                        \ call to GTDRV

 JSR GTDRV              \ Get an ASCII disc drive drive number from the keyboard
                        \ in A, setting the C flag if an invalid drive number
                        \ was entered

IF _6502SP_VERSION

 STA INWK+1             \ Store the ASCII drive number in INWK+1, which is the
                        \ drive character of the filename string ":0.E."

ELIF _MASTER_VERSION

 STA saveCommand+6      \ Store the ASCII drive number in saveCommand+6, which
                        \ is the drive character of the filename string ":1.U."

 STA loadCommand+6      \ Store the ASCII drive number in loadCommand+6, which
                        \ is the drive character of the filename string ":1.U."

ENDIF

 PLA                    \ Restore A from the stack

 BCS slod3              \ If the C flag is set, then an invalid drive number was
                        \ entered, so jump to slod3 to return from the
                        \ subroutine

IF _6502SP_VERSION

 PHA                    \ Store A on the stack so we can restore it after the
                        \ call to DODOSVN

 LDA #255               \ Set the SVN flag to 255 to indicate that disc access
 JSR DODOSVN            \ is in progress

 PLA                    \ Restore A from the stack

 LDX #INWK              \ Store a pointer to INWK at the start of the block at
 STX &0C00              \ &0C00, storing #INWK in the low byte because INWK is
                        \ in zero page

 LDX #0                 \ Set (Y X) = &0C00
 LDY #&C

 JSR OSFILE             \ Call OSFILE to do the file operation specified in
                        \ &0C00 (i.e. save or load a file depending on the value
                        \ of A)

 JSR CLDELAY            \ Pause for 1280 empty loops

 LDA #0                 \ Set the SVN flag to 0 indicate that disc access has
 JSR DODOSVN            \ finished

ELIF _MASTER_VERSION

 PHA                    \ Store A on the stack so we can restore it after the
                        \ call to SWAPZP/NMIRELEASE

IF _SNG47

 JSR SWAPZP             \ Call SWAPZP to restore the top part of zero page

ELIF _COMPACT

 JSR NMIRELEASE         \ Release the NMI workspace (&00A0 to &00A7)

ENDIF

 PLA                    \ Restore A from the stack

 BNE slod1              \ If A is non-zero then we need to load the file, so
                        \ jump to slod2

 LDX #LO(saveCommand)   \ Set (Y X) to point to the save command
 LDY #HI(saveCommand)

 BNE slod2              \ Jump to slod2 (this BNE is effectively a JMP as Y is
                        \ never zero

.slod1

 LDX #LO(loadCommand)   \ Set (Y X) to point to the load command
 LDY #HI(loadCommand)

.slod2

 JSR OSCLI              \ Call OSCLI to run the load or save OS command

 JSR SWAPZP             \ Call SWAPZP to restore the top part of zero page

ENDIF

 CLC                    \ Clear the C flag

.slod3

 RTS                    \ Return from the subroutine


\ ******************************************************************************
\
\       Name: DeleteUniverse
\       Type: Subroutine
\   Category: Universe editor
\    Summary: Catalogue a disc, ask for a filename to delete, and delete the
\             file
\
\ ------------------------------------------------------------------------------
\
\ This routine asks for a disc drive number, and if it is a valid number (0-3)
\ it displays a catalogue of the disc in that drive. It then asks for a filename
\ to delete, updates the OS command at deleteCommand so that when that command
\ is run, it it deletes the correct file, and then it does the deletion.
\
\ ******************************************************************************

.DeleteUniverse

 JSR CATS               \ Call CATS to ask for a drive number (or a directory
                        \ name on the Master Compact) and catalogue that disc
                        \ or directory

 BCS dele2              \ If the C flag is set then an invalid drive number was
                        \ entered as part of the catalogue process, so jump to
                        \ dele2 to return from the subroutine

IF _6502SP_VERSION

 LDA CTLI+1             \ The call to CATS above put the drive number into
 STA DELI+7             \ CTLI+1, so copy the drive number into DELI+7 so that
                        \ the drive number in the "DELETE:0.E.1234567" string
                        \ gets updated (i.e. the number after the colon)

 LDA #9                 \ Print extended token 9 ("{clear bottom of screen}FILE
 JSR DETOK              \ TO DELETE?")

ELIF _MASTER_VERSION

IF _SNG47

 LDA CTLI+4             \ The call to CATS above put the drive number into
 STA deleteCommand+8    \ deleteCommand+4, so copy the drive number into
                        \ deleteCommand+8 so that the drive number in the
                        \ "DELETE :1.U.1234567" string gets updated (i.e. the
                        \ number after the colon)

ENDIF

 LDA #8                 \ Print extended token 8 ("{single cap}COMMANDER'S
 JSR DETOK              \ NAME? ")

ENDIF

 JSR MT26               \ Call MT26 to fetch a line of text from the keyboard
                        \ to INWK+5, with the text length in Y

 TYA                    \ If no text was entered (Y = 0) then jump to dele2 to
 BEQ dele2              \ return from the subroutine

                        \ We now copy the entered filename from INWK to DELI, so
                        \ that it overwrites the filename part of the string,
                        \ i.e. the "E.1234567" part of "DELETE:0.E.1234567"

IF _6502SP_VERSION

 LDX #9                 \ Set up a counter in X to count from 9 to 1, so that we
                        \ copy the string starting at INWK+4+1 (i.e. INWK+5) to
                        \ DELI+8+1 (i.e. DELI+9 onwards, or "E.1234567")

ELIF _MASTER_VERSION

IF _SNG47

                        \ We now copy the entered filename from INWK to DELI, so
                        \ that it overwrites the filename part of the string,
                        \ i.e. the "E.1234567" part of "DELETE :1.1234567"

 LDX #8                 \ Set up a counter in X to count from 9 to 1, so that we
                        \ copy the string starting at INWK+4+1 (i.e. INWK+5) to
                        \ deleteCommand+9+1 (i.e. DELI+10 onwards, or
                        \ "1.1234567")
                        \
                        \ This is 9 in the original, which is a bug

ELIF _COMPACT

                        \ We now copy the entered filename from INWK to DELI, so
                        \ that it overwrites the filename part of the string,
                        \ i.e. the "1234567890" part of "DELETE 1234567890"

 LDX #8                 \ Set up a counter in X to count from 8 to 0, so that we
                        \ copy the string starting at INWK+5+0 (i.e. INWK+5) to
                        \ DELI+7+0 (i.e. DELI+7 onwards, or "1234567890")

ENDIF

ENDIF

.dele1

IF _6502SP_VERSION

 LDA INWK+4,X           \ Copy the X-th byte of INWK+4 to the X-th byte of
 STA DELI+8,X           \ DELI+8

 DEX                    \ Decrement the loop counter

 BNE dele1              \ Loop back to delt1 to copy the next character until we
                        \ have copied the whole filename

ELIF _MASTER_VERSION

IF _SNG47

 LDA INWK+4,X           \ Copy the X-th byte of INWK+4 to the X-th byte of
 STA deleteCommand+11,X \ deleteCommand+11

 DEX                    \ Decrement the loop counter

 BNE dele1              \ Loop back to dele1 to copy the next character until we
                        \ have copied the whole filename

 JSR SWAPZP             \ Call SWAPZP to restore the top part of zero page

ELIF _COMPACT

 LDA INWK+5,X           \ Copy the X-th byte of INWK+5 to the X-th byte of
 STA DELI+7,X           \ DELI+7

 DEX                    \ Decrement the loop counter

 BPL dele1              \ Loop back to dele1 to copy the next character until we
                        \ have copied the whole filename

 JSR NMIRELEASE         \ Release the NMI workspace (&00A0 to &00A7)

ENDIF

ENDIF

IF _6502SP_VERSION

 LDX #LO(DELI)          \ Set (Y X) to point to the OS command at DELI, which
 LDY #HI(DELI)          \ contains the DFS command for deleting this file


 JSR SCLI2              \ Call SCLI2 to execute the OS command at (Y X), which
                        \ deletes the file, setting the SVN flag while it's
                        \ running to indicate disc access is in progress

ELIF _MASTER_VERSION

 LDX #LO(deleteCommand) \ Set (Y X) to point to the OS command at deleteCommand,
 LDY #HI(deleteCommand) \ which contains the DFS command for deleting this file


 JSR OSCLI              \ Call OSCLI to execute the OS command at (Y X), which
                        \ catalogues the disc

 JSR SWAPZP             \ Call SWAPZP to restore the top part of zero page

ENDIF

.dele2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ChangeDirectory
\       Type: Subroutine
\   Category: Universe editor
\    Summary: Change disc directory
\
\ ******************************************************************************

.ChangeDirectory

IF _MASTER_VERSION

IF _SNG47

 JSR SWAPZP             \ Call SWAPZP to restore the top part of zero page

ELIF _COMPACT

 JSR NMIRELEASE         \ Release the NMI workspace (&00A0 to &00A7)

ENDIF

ENDIF

 LDX #LO(dirCommand)    \ Set (Y X) to point to dirCommand ("DIR U")
 LDY #HI(dirCommand)

 JSR OSCLI              \ Call OSCLI to run the OS command in dirCommand, which
                        \ changes the disc directory to E

IF _MASTER_VERSION

 JSR SWAPZP             \ Call SWAPZP to restore the top part of zero page

ENDIF

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: StoreName
\       Type: Subroutine
\   Category: Universe editor
\    Summary: Store the name of the current universe file
\
\ ******************************************************************************

.StoreName

 LDX #7                 \ The universe's name can contain a maximum of 7
                        \ characters, and is terminated by a carriage return,
                        \ so set up a counter in X to copy 8 characters

.name1

 LDA INWK+5,X           \ Copy the X-th byte of INWK+5 to the X-th byte of NA%
 STA NAME,X

 DEX                    \ Decrement the loop counter

 BPL name1              \ Loop back until we have copied all 8 bytes

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: CopyBlock
\       Type: Subroutine
\   Category: Universe editor
\    Summary: Copy a small block of memory
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   Y                   Number of bytes to copy - 1
\
\   P(1 0)              From address
\
\   Q(1 0)              To address
\
\ ******************************************************************************

.CopyBlock

 LDA (P),Y              \ Copy byte X from P(1 0) to Q(1 0)
 STA (Q),Y

 DEY                    \ Decrement the counter

 BPL CopyBlock          \ Loop back until all X bytes are copied

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: showingBulb
\       Type: Variable
\   Category: Universe editor
\    Summary: A status byte showing which bulbs are being shown on the dashboard
\
\ ------------------------------------------------------------------------------
\
\ The status byte is as follows:
\
\   * Bit 6 is set if the S bulb is showing
\
\   * Bit 7 is set if the E bulb is showing
\
\ ******************************************************************************

.showingBulb

 EQUB 0

\ ******************************************************************************
\
\       Name: dashboardBuff
\       Type: Variable
\   Category: Universe editor
\    Summary: Buffer for changing the dashboard
\
\ ******************************************************************************

IF _6502SP_VERSION

.dashboardBuff

 EQUB 2                 \ The number of bytes to transmit with this command

 EQUB 2                 \ The number of bytes to receive with this command

ENDIF


\ ******************************************************************************
\
\       Name: TWIST
\       Type: Subroutine
\   Category: Universe editor
\    Summary: Pitch the current ship by a small angle in a positive direction
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   TWIST2              Pitch in the direction given in A
\
\ ******************************************************************************

IF _MASTER_VERSION

.TWIST2

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &00, or BIT &00A9, which does nothing apart
                        \ from affect the flags

.TWIST

 LDA #0                 \ Set A = 0

 STA RAT2               \ Set the pitch direction in RAT2 to A

 LDX #15                \ Rotate (roofv_x, nosev_x) by a small angle (pitch)
 LDY #9                 \ in the direction given in RAT2
 JSR MVS5

 LDX #17                \ Rotate (roofv_y, nosev_y) by a small angle (pitch)
 LDY #11                \ in the direction given in RAT2
 JSR MVS5

 LDX #19                \ Rotate (roofv_z, nosev_z) by a small angle (pitch)
 LDY #13                \ in the direction given in RAT2 and return from the
 JMP MVS5               \ subroutine using a tail call

ENDIF

\ ******************************************************************************
\
\       Name: STORE
\       Type: Subroutine
\   Category: Universe editor
\    Summary: Copy the ship data block at INWK back to the K% workspace
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   INF                 The ship data block in the K% workspace to copy INWK to
\
\ ******************************************************************************

IF _MASTER_VERSION

.STORE

 LDY #(NI%-1)           \ Set a counter in Y so we can loop through the NI%
                        \ bytes in the ship data block

.DML2

 LDA INWK,Y             \ Load the Y-th byte of INWK and store it in the Y-th
 STA (INF),Y            \ byte of INF

 DEY                    \ Decrement the loop counter

 BPL DML2               \ Loop back for the next byte, until we have copied the
                        \ last byte from INWK back to INF

 RTS                    \ Return from the subroutine

ENDIF


\ ******************************************************************************
\
\       Name: ZEBC
\       Type: Subroutine
\   Category: Universe editor
\    Summary: Zero-fill pages &B and &C
\
\ ******************************************************************************

IF _MASTER_VERSION

.ZEBC

 LDX #&C                \ Call ZES1 with X = &C to zero-fill page &C
 JSR ZES1

 DEX                    \ Decrement X to &B

 JMP ZES1               \ Jump to ZES1 to zero-fill page &B

ENDIF

.endUniverseEditor3
