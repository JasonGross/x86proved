(*===========================================================================
  Implementation of CGA screen functions
  ===========================================================================*)
Require Import Ssreflect.ssreflect Ssreflect.ssrbool Ssreflect.ssrnat Ssreflect.eqtype Ssreflect.seq Ssreflect.fintype Ssreflect.tuple.
Require Import x86proved.x86.procstate x86proved.x86.procstatemonad x86proved.bitsrep x86proved.bitsops x86proved.bitsprops x86proved.bitsopsprops.
Require Import x86proved.x86.program x86proved.x86.macros.
Require Import x86proved.x86.instr x86proved.x86.instrsyntax x86proved.x86.instrcodec x86proved.reader x86proved.cursor x86proved.x86.screenspec x86proved.examples.mulc.

Set Implicit Arguments.
Unset Strict Implicit.
Import Prenex Implicits.

Local Open Scope instr_scope.

(* Compute line position EDX in screen buffer starting at EDI *)
(* EDI contains the position; EDX is trashed *)
Definition inlineComputeLinePos: program :=
     add_mulcFast EDI EDX #(numCols*2).

(* Compute (in EDI) the screen address of the character specified by ECX (column)
   and EDX (row). ECX and EDX get trashed. *)
Definition inlineComputeCharPos: program :=
     MOV EDI, screenBase;;
     SHL EDX, 5;;
     ADD EDI, EDX;;
     SHL EDX, 2;;
     ADD EDI, EDX;;
     SHL ECX, 1;;
     ADD EDI, ECX.


(* Output character in AL at position specified by CX (column) and DX (row) *)
Definition inlineOutputChar :=
  inlineComputeCharPos;;
  MOV [EDI], AL.

Definition inlineReadChar :=
  inlineComputeCharPos;;
  MOV AL, [EDI].

Definition clearColour := toNat (n:=8) (#x"4F").

(* Code for clear screen. *)
(* Todo: get syntax for byte instructions to work! *)
Definition clsProg:program :=
      MOV EBX, screenBase;;
      while (CMP EBX, screenLimit) CC_B true ( (* while EBX < screenLimit *)
        MOV BYTE [EBX], #c" ";;
        MOV BYTE [EBX+1], # clearColour;;
        INC EBX;; INC EBX (* move one character right on the screen *)
      ).
