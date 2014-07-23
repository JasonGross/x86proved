(** * PUSH instruction *)
Require Import x86proved.x86.instrrules.core.
Import x86.instrrules.core.instrruleconfig.

(** ** Generic rule *)
Lemma PUSH_rule src sp (v:DWORD) :
  |-- specAtSrc src (fun w =>
      basic    (ESP ~= sp    ** sp-#4 :-> v) (PUSH src) empOP
               (ESP ~= sp-#4 ** sp-#4 :-> w)).
Proof. do_instrrule_triple. Qed.

(** We make this rule an instance of the typeclass, after unfolding various things in its type. *)
Section handle_type_of_rule.
  Context (src : Src).
  Let rule := @PUSH_rule src.
  Let T := Eval cbv beta iota zeta delta [specAtSrc] in (fun T (x : T) => T) _ rule.
  Global Instance: instrrule (PUSH src) := rule : T.
End handle_type_of_rule.

Ltac basicPUSH :=
  let R := lazymatch goal with
             | |- |-- basic ?p (PUSH ?a) ?O ?q => constr:(PUSH_rule a)
           end in
  instrrules_basicapply R.

(** ** PUSH r *)
Corollary PUSH_R_rule (r:Reg) sp (v w:DWORD) :
  |-- basic (r ~= v ** ESP ~= sp    ** sp-#4 :-> w)
            (PUSH r) empOP
            (r ~= v ** ESP ~= sp-#4 ** sp-#4 :-> v).
Proof. basicPUSH. Qed.

(** ** PUSH v *)
Corollary PUSH_I_rule (sp v w:DWORD) :
  |-- basic (ESP ~= sp    ** sp-#4 :-> w)
            (PUSH v) empOP
            (ESP ~= sp-#4 ** sp-#4 :-> v).
Proof. basicPUSH. Qed.

(** ** PUSH [r + offset] *)
Corollary PUSH_M_rule (r: Reg) (offset:nat) (sp v w pbase:DWORD) :
  |-- basic (r ~= pbase ** pbase +# offset :-> v ** ESP ~= sp    ** sp-#4 :-> w)
            (PUSH [r + offset]) empOP
            (r ~= pbase ** pbase +# offset :-> v ** ESP ~= sp-#4 ** sp-#4 :-> v).
Proof. basicPUSH. Qed.

(** ** PUSH [r] *)
Corollary PUSH_M0_rule (r: Reg) (sp v w pbase:DWORD) :
  |-- basic (r ~= pbase ** pbase :-> v ** ESP ~= sp    ** sp-#4 :-> w)
            (PUSH [r]) empOP
            (r ~= pbase ** pbase :-> v ** ESP ~= sp-#4 ** sp-#4 :-> v).
Proof. basicPUSH. Qed.
