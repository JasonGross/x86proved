(*===========================================================================
    Model for x86 memory

    Note that operations are partial, as not all memory is mapped
    A more refined model would incorporate R/W/X permissions, on the
    appropriate granularity.

    BEWARE of "punning" this partiality for the purpose of defining
    separating conjunction: we will at some point wish to talk about *separate*
    regions of memory not all of which are accessible under given permissions,
    and the re-use of partiality for separation would preclude this.
  ===========================================================================*)
Require Import Ssreflect.ssreflect Ssreflect.ssrfun Ssreflect.ssrnat Ssreflect.ssrbool Ssreflect.finfun Ssreflect.eqtype Ssreflect.fintype Ssreflect.seq Ssreflect.tuple.
Require Import x86proved.bitsrep x86proved.bitsops x86proved.cursor x86proved.reader x86proved.writer.
Require Export x86proved.pmap x86proved.x86.addr.
Local Open Scope update_scope.

Set Implicit Arguments.
Unset Strict Implicit.
Import Prenex Implicits.


(* 64-bit addressable memory *)
(*=Mem *)
Definition Mem := PMAP BYTE naddrBits.
(*=End *)

(* Initially, no memory is mapped *)
Definition initialMemory : Mem := @EmptyPMap BYTE _.

(* Memory from p to just below p' in m consists exactly of the bytes in xs *)
Fixpoint memIs (m:Mem) (p p':ADDR) xs :=
  if xs is x::xs then m p = Some x /\ memIs m (incB p) p' xs else p=p'.


(* Map some memory, filling it with ones (to be more visible!) *)
Definition reserveMemory (m: Mem) (p:ADDR) c : Mem :=
  bIterFrom p c (fun p m => m !p := ones 8) m.

Definition isMapped (p:ADDR) (ms: Mem) : bool := ms p.

(*
Instance MemUpdateOpsDWORD : UpdateOps Mem ADDR DWORD :=
  fun m p v =>
  let: [::tuple b0;b1;b2;b3] := bitsToBytes 4 v in
  m !p:=b0 !incB p:=b1 !incB(incB p):=b2 !incB(incB(incB p)):=b3.
*)

(*
Instance MemUpdateDWORD : Update Mem DWORD DWORD.
Proof.
apply Build_Update.
move => m p v w.
rewrite /update /MemUpdateOpsDWORD.
destruct (DWORDToBytes w) as [[[b3 b2] b1] b0].
destruct (DWORDToBytes v) as [[[b7 b6] b5] b4].
rewrite (update_diff _ _ p).
rewrite (update_diff _ _ p).
rewrite (update_diff _ _ p).
rewrite update_same.
rewrite (update_diff _ _ (incB p)).
rewrite (update_diff _ _ (incB p)).
rewrite update_same.
rewrite (update_diff _ _ (incB (incB p)) _ b2).
rewrite update_same.
rewrite update_same.
done.
apply incBDistinct.
apply incBDistinct.
apply incBincBDistinct.
apply incBDistinct.
apply incBincBDistinct.
apply incBincBincBDistinct.

move => m p q v w pq.
rewrite /update /MemUpdateOpsDWORD.
destruct (DWORDToBytes w) as [[[b3 b2] b1] b0].
destruct (DWORDToBytes v) as [[[b7 b6] b5] b4].

rewrite (update_diff _ (incB (incB p))).  Implicit update_diff. rewrite update_same.
simpl.
Definition updateBYTE (p:DWORD) (b:BYTE) (ms: Mem) : option Mem :=
  if isMapped p ms then Some (ms !p := b) else None.

*)

(*---------------------------------------------------------------------------
   We define a type of "readers of T", such that

   read m p = readerFail if memory at p in m is inaccessible for reading T
   read m p = readerWrap if we tried to read beyond the end of memory
   read m p = readerOk x q if memory between p inclusive and q exclusive represents x:X
  ---------------------------------------------------------------------------*)
Inductive readerResult T :=
  readerOk (x: T) (q: ADDRCursor) | readerWrap | readerFail.
Implicit Arguments readerOk [T].
Implicit Arguments readerWrap [T].
Implicit Arguments readerFail [T].

Fixpoint readMem T (r:Reader T) (m:Mem) (pos:ADDRCursor) : readerResult T :=
  match r with
  | readerRetn x => readerOk x pos
  | readerNext rd =>
    if pos is mkCursor p
    then if m p is Some x then readMem (rd x) m (next p) else readerFail
    else readerWrap
  | readerSkip rd =>
    if pos is mkCursor p
    then if m p is Some x then readMem rd m (next p) else readerFail
    else readerWrap
  | readerCursor rd =>
    readMem (rd pos) m pos
  end.

(* Example of interpretation of writer on sequences *)
Fixpoint writeMemTm (w:WriterTm unit) (m:Mem) (pos: ADDRCursor) :
    option (ADDRCursor * Mem) :=
  match w with
  | writerRetn _ => Some (pos, m)
  | writerNext byte w =>
    if pos is mkCursor p
    then
      if isMapped p m
      then writeMemTm w (m!p:=byte) (next p)
      else None
    else None
  | writerSkip w =>
    if pos is mkCursor p
    then
      if isMapped p m
      then writeMemTm w (m!p:=#0) (next p)
      else None
    else None
  | writerCursor w =>
    writeMemTm (w pos) m pos
  | writerFail =>
    None
  end.

Definition writeMem {T} (w:Writer T) (m:Mem) (pos: ADDRCursor) (t: T):
    option (ADDRCursor * Mem) :=
  writeMemTm (w t) m pos.

Require Import Coq.Strings.String.
Import Ascii.
Fixpoint enumMemToString (xs: seq (ADDR * BYTE)) :=
  (if xs is (p,b)::xs then toHex p ++ ":=" ++ toHex b ++ ", " ++ enumMemToString xs
  else "")%string.

Definition memToString (m:Mem) := enumMemToString (enumPMap m).

Example m: Mem := (@EmptyPMap _ _) ! #5 := (#12:BYTE) !#8 := (#15:BYTE).
