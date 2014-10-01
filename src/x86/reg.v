(*===========================================================================
    Model for x86 registers
    Note that the EFL register (flags) is treated separately.

    These are registers as used inside instructions, and can refer to
    overlapping sections of the real machine state e.g. AL, AH, AX, EAX
  ===========================================================================*)
Require Import Ssreflect.ssreflect Ssreflect.ssrfun Ssreflect.ssrbool Ssreflect.eqtype Ssreflect.ssrnat Ssreflect.seq Ssreflect.choice Ssreflect.fintype Ssreflect.tuple.
Require Import x86proved.bitsrep.

(* General purpose registers, excluding RSP and RIP *)
(*=NonSPReg64 *)
Inductive NonSPReg64 := 
  RAX | RBX | RCX | RDX | RSI | RDI | RBP
| R8  | R9  | R10 | R11 | R12 | R13 | R14 | R15.
(*=End *)
Definition NonSPReg64_toNat r :=
  match r with RAX => 0 | RCX => 1 | RDX => 2 | RBX => 3 | RBP => 5 | RSI => 6 | RDI => 7 
             | R8 => 8 | R9 => 9 | R10 => 10 | R11 => 11 | R12 => 12 | R13 => 13 | R14 => 14 | R15 => 15 end.
Lemma NonSPReg64_toNat_inj : injective NonSPReg64_toNat. Proof. by repeat case => //. Qed.
Canonical Structure NonSPReg64_EqMixin := InjEqMixin NonSPReg64_toNat_inj.
Canonical Structure NonSPReg64_EqType := Eval hnf in EqType _ NonSPReg64_EqMixin.

(* General purpose registers: x86 has eight, x64 has sixteen *)
(*=GPReg64 *)
Inductive GPReg64 := mkGPReg64 (r: NonSPReg64) :> GPReg64 | RSP.
(*=End *)
Definition GPReg64_toNat r :=  match r with | RSP => 4 | mkGPReg64 r => NonSPReg64_toNat r end.
Lemma GPReg64_toNat_inj : injective GPReg64_toNat. Proof. by repeat case => //. Qed.
Canonical Structure GPReg64_EqMixin := InjEqMixin GPReg64_toNat_inj.
Canonical Structure GPReg64_EqType := Eval hnf in EqType _ GPReg64_EqMixin.

(* All general purpose registers, including RIP but still excluding the flags *)
(*=Reg64 *)
Inductive Reg64 := mkReg64 (r: GPReg64) :> Reg64 | RIP.
(*=End *)
Definition Reg64_toNat r :=  match r with | RIP => 16 | mkReg64 r => GPReg64_toNat r end.
Lemma Reg64_toNat_inj : injective Reg64_toNat. Proof. by repeat case => //. Qed.
Canonical Structure Reg64_EqMixin := InjEqMixin Reg64_toNat_inj.
Canonical Structure Reg64_EqType := Eval hnf in EqType _ Reg64_EqMixin.


(* Addressable 32-bit slices of above *)
Inductive NonSPReg32 := mkNonSPReg32 (r: NonSPReg64).
Definition NonSPReg32_base r32 := let: mkNonSPReg32 r := r32 in r.
Lemma NonSPReg32_base_inj : injective NonSPReg32_base. Proof. move => [x] [y] [/=E]. by subst. Qed. 
Canonical Structure NonSPReg32_EqMixin := InjEqMixin NonSPReg32_base_inj.
Canonical Structure NonSPReg32_EqType := Eval hnf in EqType _ NonSPReg32_EqMixin.

Inductive GPReg32 := mkGPReg32 (r: GPReg64).
Definition GPReg32_base r32 := let: mkGPReg32 r := r32 in r.
Lemma GPReg32_base_inj : injective GPReg32_base. Proof. move => [x] [y] [/=E]. by subst. Qed. 
Canonical Structure GPReg32_EqMixin := InjEqMixin GPReg32_base_inj.
Canonical Structure GPReg32_EqType := Eval hnf in EqType _ GPReg32_EqMixin.

Inductive Reg32 := mkReg32 (r: Reg64).
Definition Reg32_base r32 := let: mkReg32 r := r32 in r.
Lemma Reg32_base_inj : injective Reg32_base. Proof. move => [x] [y] [/=E]. by subst. Qed. 
Canonical Structure Reg32_EqMixin := InjEqMixin Reg32_base_inj.
Canonical Structure Reg32_EqType := Eval hnf in EqType _ Reg32_EqMixin.

Coercion NonSPReg32_to_GPReg32 (r: NonSPReg32) := mkGPReg32 (NonSPReg32_base r).
Coercion GPReg32_to_Reg32 (r: GPReg32) := mkReg32 (GPReg32_base r).

Notation EAX := (mkNonSPReg32 RAX).
Notation EBX := (mkNonSPReg32 RBX).
Notation ECX := (mkNonSPReg32 RCX).
Notation EDX := (mkNonSPReg32 RDX).
Notation ESI := (mkNonSPReg32 RSI).
Notation EDI := (mkNonSPReg32 RDI).
Notation EBP := (mkNonSPReg32 RBP).
Notation R8D := (mkNonSPReg32 R8).
Notation R9D := (mkNonSPReg32 R9).
Notation R10D := (mkNonSPReg32 R10).
Notation R11D := (mkNonSPReg32 R11).
Notation R12D := (mkNonSPReg32 R12).
Notation R13D := (mkNonSPReg32 R13).
Notation R14D := (mkNonSPReg32 R14).
Notation R15D := (mkNonSPReg32 R15).
Notation ESP := (mkGPReg32 RSP).
Notation EIP := (mkReg32 RIP).

(* Addressable 16-bit slices of above *)
Inductive NonSPReg16 := mkNonSPReg16 (r: NonSPReg64).
Definition NonSPReg16_base r16 := let: mkNonSPReg16 r := r16 in r.
Lemma NonSPReg16_base_inj : injective NonSPReg16_base. Proof. move => [x] [y] [/=E]. by subst. Qed. 
Canonical Structure NonSPReg16_EqMixin := InjEqMixin NonSPReg16_base_inj.
Canonical Structure NonSPReg16_EqType := Eval hnf in EqType _ NonSPReg16_EqMixin.

Inductive GPReg16 := mkGPReg16 (r: GPReg64).
Definition GPReg16_base r16 := let: mkGPReg16 r := r16 in r.
Lemma GPReg16_base_inj : injective GPReg16_base. Proof. move => [x] [y] [/=E]. by subst. Qed. 
Canonical Structure GPReg16_EqMixin := InjEqMixin GPReg16_base_inj.
Canonical Structure GPReg16_EqType := Eval hnf in EqType _ GPReg16_EqMixin.

Inductive Reg16 := mkReg16 (r: Reg64).
Definition Reg16_base r16 := let: mkReg16 r := r16 in r.
Lemma Reg16_base_inj : injective Reg16_base. Proof. move => [x] [y] [/=E]. by subst. Qed. 
Canonical Structure Reg16_EqMixin := InjEqMixin Reg16_base_inj.
Canonical Structure Reg16_EqType := Eval hnf in EqType _ Reg16_EqMixin.

Coercion NonSPReg16_to_GPReg16 (r: NonSPReg16) := mkGPReg16 (NonSPReg16_base r).
Coercion GPReg16_to_Reg16 (r: GPReg16) := mkReg16 (GPReg16_base r).

Notation AX := (mkNonSPReg16 RAX).
Notation BX := (mkNonSPReg16 RBX).
Notation CX := (mkNonSPReg16 RCX).
Notation DX := (mkNonSPReg16 RDX).
Notation SI := (mkNonSPReg16 RSI).
Notation DI := (mkNonSPReg16 RDI).
Notation BP := (mkNonSPReg16 RBP).
Notation R8W := (mkNonSPReg16 R8).
Notation R9W := (mkNonSPReg16 R9).
Notation R10W := (mkNonSPReg16 R10).
Notation R11W := (mkNonSPReg16 R11).
Notation R12W := (mkNonSPReg16 R12).
Notation R13W := (mkNonSPReg16 R13).
Notation R14W := (mkNonSPReg16 R14).
Notation R15W := (mkNonSPReg16 R15).
Notation SP := (mkGPReg16 RSP).
Notation IP := (mkReg16 RIP).


(* Addressable 8-bit slices of above *)
Inductive NonSPReg8 := mkNonSPReg8 (r: NonSPReg64).
Definition NonSPReg8_base r8 := let: mkNonSPReg8 r := r8 in r.
Lemma NonSPReg8_base_inj : injective NonSPReg8_base. Proof. move => [x] [y] [/=E]. by subst. Qed. 
Canonical Structure NonSPReg8_EqMixin := InjEqMixin NonSPReg8_base_inj.
Canonical Structure NonSPReg8_EqType := Eval hnf in EqType _ NonSPReg8_EqMixin.

Inductive Reg8 := mkReg8 (r: GPReg64).
Definition Reg8_base r8 := let: mkReg8 r := r8 in r.
Lemma Reg8_base_inj : injective Reg8_base. Proof. move => [x] [y] [/=E]. by subst. Qed. 
Canonical Structure Reg8_EqMixin := InjEqMixin Reg8_base_inj.
Canonical Structure Reg8_EqType := Eval hnf in EqType _ Reg8_EqMixin.

Coercion NonSPReg8_to_Reg8 (r: NonSPReg8) := mkReg8 (NonSPReg8_base r).

Notation AL := (mkNonSPReg8 RAX).
Notation BL := (mkNonSPReg8 RBX).
Notation CL := (mkNonSPReg8 RCX).
Notation DL := (mkNonSPReg8 RDX).
Notation SIL := (mkNonSPReg8 RSI).
Notation DIL := (mkNonSPReg8 RDI).
Notation BPL := (mkNonSPReg8 RBP).
Notation R8L := (mkNonSPReg8 R8).
Notation R9L := (mkNonSPReg8 R9).
Notation R10L := (mkNonSPReg8 R10).
Notation R11L := (mkNonSPReg8 R11).
Notation R12L := (mkNonSPReg8 R12).
Notation R13L := (mkNonSPReg8 R13).
Notation R14L := (mkNonSPReg8 R14).
Notation R15L := (mkNonSPReg8 R15).
Notation SPL := (mkReg8 RSP).

(*
(* Legacy 8-bit registers *)
Inductive Reg8alt := AL|BL|CL|DL|AH|BH|CH|DH.
*)



(* Segment registers *)
Inductive SegReg := CS | DS | SS | ES | FS | GS.
Definition SegRegToNat r :=  
  match r with CS => 0 | DS => 1 | SS => 2 | ES => 3 | FS => 4 | GS => 5 end. 
Lemma SegRegToNat_inj : injective SegRegToNat. Proof. by repeat case => //. Qed.
Canonical Structure SegRegEqMixin := InjEqMixin SegRegToNat_inj.
Canonical Structure SegRegEqType := Eval hnf in EqType _ SegRegEqMixin.

(*
Definition anyRegToAnyQWORDReg (r:DWORDReg):AnyQWORDReg :=
  match r with 
  | EIP => RIP
  | regToDWORDReg r => regToQWORDReg r
  end.

Definition WORDRegToReg (wr:WORDReg):Reg := let: mkWordReg r := wr in r.
Lemma WORDRegToReg_inj : injective WORDRegToReg.
Proof. by move => [x] [y] /= ->. Qed. 
Canonical Structure WORDRegEqMixin := InjEqMixin WORDRegToReg_inj.
Canonical Structure WORDRegEqType := Eval hnf in EqType _ WORDRegEqMixin.

(* Standard numbering of registers *)
Definition natToReg n : option Reg :=
  match n return option Reg with
  | 0 => Some (EAX:Reg)
  | 1 => Some (ECX:Reg)
  | 2 => Some (EDX:Reg)
  | 3 => Some (EBX:Reg)
  | 4 => Some (ESP:Reg)
  | 5 => Some (EBP:Reg)
  | 6 => Some (ESI:Reg)
  | 7 => Some (EDI:Reg)
  | _ => None
  end.

Lemma roundtripReg : forall r, natToReg (RegToNat r) = Some r.
Proof. case. by case. done. Qed.

(* Reg is a choiceType and a countType *)
Definition Reg_countMixin := CountMixin roundtripReg.
Definition Reg_choiceMixin := CountChoiceMixin Reg_countMixin.
Canonical Reg_choiceType :=  Eval hnf in ChoiceType _ Reg_choiceMixin.
Canonical Reg_countType  :=  Eval hnf in CountType _ Reg_countMixin.

(* Reg is a finType *)
Lemma Reg_enumP :
  Finite.axiom [:: EAX:Reg; EBX:Reg; ECX:Reg; EDX:Reg; ESI:Reg; EDI:Reg; EBP:Reg; ESP].
Proof. case;  [by case | done]. Qed.

Definition Reg_finMixin := Eval hnf in FinMixin Reg_enumP.
Canonical Reg_finType   := Eval hnf in FinType _ Reg_finMixin.

(* Standard numbering of registers *)
Definition natToDWORDReg n :=
  match natToReg n with
  | Some r => Some (regToDWORDReg r)
  | None => match n with 8 => Some EIP | _ => None end
  end.

Lemma roundtripDWORDReg : forall r, natToDWORDReg (DWORDRegToNat r) = Some r.
Proof. case. case; [case; by constructor | done]. done. Qed.

(* DWORDReg is a choiceType and a countType *)
Definition DWORDReg_countMixin := CountMixin roundtripDWORDReg.
Definition DWORDReg_choiceMixin := CountChoiceMixin DWORDReg_countMixin.
Canonical DWORDReg_choiceType := Eval hnf in ChoiceType _ DWORDReg_choiceMixin.
Canonical DWORDReg_countType  := Eval hnf in CountType  _ DWORDReg_countMixin.

(* DWORDReg is a finType *)
Lemma DWORDReg_enumP :
  Finite.axiom [:: EAX:DWORDReg; EBX:DWORDReg; ECX:DWORDReg;
                   EDX:DWORDReg; ESI:DWORDReg; EDI:DWORDReg; EBP:DWORDReg; ESP:DWORDReg; EIP].
Proof. case; [case; [case; done | done] | done]. Qed.

Definition DWORDReg_finMixin := Eval hnf in FinMixin DWORDReg_enumP.
Canonical DWORDReg_finType :=  Eval hnf in FinType _ DWORDReg_finMixin.

*)

(*---------------------------------------------------------------------------
    Register pieces: these are the bytes that make up the register state
  ---------------------------------------------------------------------------*)
Definition RegIx := nat (* Could use 'I_8 for stronger typing *). 

Inductive RegPiece := mkRegPiece (r: Reg64) (ix: RegIx).
Definition RegPieceToCode rp :=  let: mkRegPiece r b := rp in (Reg64_toNat r, b). 
Lemma RegPieceToCode_inj : injective RegPieceToCode.
Proof. move => [r1 b1] [r2 b2] /=. move => [H1 H2]. apply Reg64_toNat_inj in H1. by subst. Qed. 

Canonical Structure RegPieceEqMixin := InjEqMixin RegPieceToCode_inj.
Canonical Structure RegPieceEqType := Eval hnf in EqType _ RegPieceEqMixin.

(* This should go somewhere else really *)
Definition getRegPiece (v: QWORD) (ix: RegIx) := 
  match (*val*) ix with
  | 0 => slice 0 8 _ v  
  | 1 => slice 8 8 _ v 
  | 2 => slice 16 8 _ v 
  | 3 => slice 24 8 _ v   
  | 4 => slice 32 8 _ v   
  | 5 => slice 40 8 _ v   
  | 6 => slice 48 8 _ v   
  | 7 => slice 56 8 _ v
  | _ => #0
  end.

(*tnth (bitsToBytes 8 v) ix. *)
Definition putRegPiece (v: QWORD) (ix: RegIx) (b: BYTE) : QWORD :=
  match (*val*) ix with
  | 0 => updateSlice 0 8 _ v b 
  | 1 => updateSlice 8 8 _ v b 
  | 2 => updateSlice 16 8 _ v b 
  | 3 => updateSlice 24 8 _ v b  
  | 4 => updateSlice 32 8 _ v b  
  | 5 => updateSlice 40 8 _ v b  
  | 6 => updateSlice 48 8 _ v b  
  | 7 => updateSlice 56 8 _ v b  
  | _ => v
  end.
  
Require Import bitsprops.
Lemma getRegPiece_ext (v w: QWORD) :
  (forall ix, getRegPiece v ix = getRegPiece w ix) ->
  v = w. 
Proof. rewrite /getRegPiece. move => H0. admit. 
Qed.

(*
Definition BYTERegToRegPiece (r:BYTEReg) :=
match r with
| AL => DWORDRegPiece RAX (inord 0)
| AH => DWORDRegPiece RAX (inord 1)
| BL => DWORDRegPiece RBX (inord 0)
| BH => DWORDRegPiece RBX (inord 1)
| CL => DWORDRegPiece RCX (inord 0)
| CH => DWORDRegPiece RCX (inord 1)
| DL => DWORDRegPiece RDX (inord 0)
| DH => DWORDRegPiece RDX (inord 1)
end.

*)

(* 8, 16, 32 or 64 bit registers *)
Definition NonSPReg (s: OpSize) := 
  match s with OpSize1 => NonSPReg8 | OpSize2 => NonSPReg16 | OpSize4 => NonSPReg32 | OpSize8 => NonSPReg64 end.

Definition GPReg (s: OpSize) := 
  match s with OpSize1 => Reg8 | OpSize2 => GPReg16 | OpSize4 => GPReg32 | OpSize8 => GPReg64 end.

Definition Reg (s: OpSize) :=
  match s with OpSize1 => Reg8 | OpSize2 => Reg16 | OpSize4 => Reg32 | OpSize8 => Reg64 end.
  
Coercion NonSPReg_to_Reg {s} : NonSPReg s -> Reg s  := 
  match s return NonSPReg s -> Reg s with 
  OpSize1 => fun r => r | OpSize2 => fun r => r | OpSize4 => fun r => r | OpSize8 => fun r => r end. 

Coercion GPReg_to_Reg {s} : GPReg s -> Reg s  := 
  match s return GPReg s -> Reg s with 
  OpSize1 => fun r => r | OpSize2 => fun r => r | OpSize4 => fun r => r | OpSize8 => fun r => r end. 

Coercion Reg64_to_Reg (r:Reg64) : Reg OpSize8 := r.
Coercion Reg32_to_Reg (r:Reg32) : Reg OpSize4 := r.
Coercion Reg16_to_Reg (r:Reg16) : Reg OpSize2 := r.
Coercion Reg8_to_Reg (r:Reg8)   : Reg OpSize1 := r.

Coercion GPReg64_to_GPReg (r:GPReg64) : GPReg OpSize8 := r.
Coercion GPReg32_to_GPReg (r:GPReg32) : GPReg OpSize4 := r.
Coercion GPReg16_to_GPReg (r:GPReg16) : GPReg OpSize2 := r.
Coercion Reg8_to_GPReg (r:Reg8) : GPReg OpSize1 := r.
