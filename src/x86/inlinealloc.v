Require Import Ssreflect.ssreflect Ssreflect.ssrbool Ssreflect.ssrnat Ssreflect.eqtype Ssreflect.seq Ssreflect.fintype.
Require Import x86proved.x86.procstate x86proved.x86.procstatemonad x86proved.bitsops x86proved.bitsprops x86proved.bitsopsprops.
Require Import x86proved.spred x86proved.septac x86proved.spec x86proved.spectac x86proved.x86.basic x86proved.x86.program x86proved.x86.macros.
Require Import x86proved.x86.instr x86proved.x86.instrsyntax x86proved.x86.instrcodec x86proved.x86.instrrules x86proved.reader x86proved.pointsto x86proved.cursor.
Require Import x86proved.chargetac x86proved.latertac.

Set Implicit Arguments.
Unset Strict Implicit.
Import Prenex Implicits.

Local Open Scope instr_scope.
(* Allocation invariant:
     infoBlock points to a pair of DWORDs:
       base, a pointer to the current available heap
       count, the number of bytes currently available
   Furthermore, "count" bytes of memory starting at "base" is defined
*)
Definition allocInv (infoBlock: DWORD) :=
  Exists base: DWORD,
  Exists count: DWORD,
  infoBlock :-> base **
  infoBlock +#4 :-> count **
  memAny base count.

(* Allocate memory.
     infoBlock: Src  is pointer to two-word heap information block
     n: nat representing number of bytes to be allocated
     failed: DWORD is label to branch to on failure
   If successful, EDI contains pointer to byte just beyond allocated block.
*)
Definition allocImp (infoBlock:DWORD) (n: nat) (failed: DWORD) : program :=
  MOV EDI, [infoBlock];;
  ADD EDI, n;;
  JC  failed;;  (* A carry indicates unsigned overflow *)
  CMP [infoBlock+#4:DWORD], EDI;;
  JC  failed;;  (* A carry indicates unsigned underflow *)
  MOV [infoBlock], EDI.

Definition allocSpec n (fail:DWORD) inv code :=
  Forall i j : DWORD, (
      safe @ (EIP ~= fail ** EDI?) //\\
      safe @ (EIP ~= j ** Exists p, EDI ~= p +# n ** memAny p (p +# n))
    -->>
      safe @ (EIP ~= i ** EDI?)
    )
    @ (OSZCP? ** inv)
    c@ (i -- j :-> code).

Hint Unfold allocSpec : specapply.

(* Perhaps put a |> on the failLabel case *)
Require Import x86proved.basicspectac.
Lemma inlineAlloc_correct n failed infoBlock : |-- allocSpec n failed (allocInv infoBlock) (allocImp infoBlock n failed).
Proof.
  rewrite /allocSpec/allocImp.
  specintros => *. 
  unfold_program. specintros => *.
  (* Push invariant under implication so that we can instantiate existential pre and post *)
  rewrite spec_at_impl. rewrite /allocInv. specintros => base limit. 

  (* MOV EDI, [infoBlock] *)  
  superspecapply MOV_RanyInd_rule. 

  (* ADD EDI, bytes *)
  superspecapply *. 

  (* JC failed *)
  rewrite /OSZCP. 
  superspecapply JC_rule. 

  specsplit.
  simpllater. (*rewrite <- spec_frame. *) finish_logic_with sbazooka.

  (* CMP [infoBlock+#4], EDI *)
  specintro => /eqP => Hcarry. 

  specapply CMP_IndR_ZC_rule; rewrite /stateIsAny; sbazooka. 

  (* JC failed *)
  superspecapply JC_rule. 
  specsplit.
  - simpllater. (*rewrite <- spec_frame. *) finish_logic_with sbazooka.

  (* MOV [infoBlock], EDI *)
  superspecapply MOV_IndR_rule. 

  specintro => /eqP LT.

  { (*rewrite <- spec_frame. *) rewrite /stateIsAny/natAsDWORD. finish_logic. (*apply limplValid.
    autorewrite with push_at. *) apply landL2. finish_logic_with sbazooka.  

    apply memAnySplit.
    { apply: addB_leB.
      apply injective_projections; [ by rewrite Hcarry
                                   | by generalize @adcB ]. }
    { simpl. rewrite ltBNle /natAsDWORD in LT. rewrite -> Bool.negb_false_iff in LT. by rewrite LT. } }
Qed.
