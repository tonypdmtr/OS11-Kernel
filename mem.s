* *****************************************************************
* * FILENAME:	mem.s                                             *
* * AUTHOR:     meier@msoe.edu <Dr. M.>                           *
* * PROVIDES:   user ram start and end addresses                  *
* * DATE:       7 Dec 2005                                        *
* * PROJECT:    OS11                                              *
* *****************************************************************

STACK		EQU	$8500		; placed stack low since it is small
DATA		EQU	$8600		; added four pages for data bytes
CODE		EQU	$9000		; remainder of RAM is for code

RAM		EQU	$8400		; start of user RAM
RAMEND	EQU	$DFFF		; end of user RAM

