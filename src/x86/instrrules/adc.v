(** * ADC instruction *)
Require Import x86.instrrules.core.
Import x86.instrrules.core.instrruleconfig.

(** TODO(t-jagro): Generalize this to [DWORDorBYTE] *)
Lemma ADC_rule d (ds:DstSrc d) v1 o s z (c : bool) p
: |-- specAtDstSrc ds (fun D v2 =>
                         basic (D v1 ** OSZCP o s z c p)
                               (BOP d OP_ADC ds)
                               (let (carry, v) := eta_expand (adcB c v1 v2) in
                                D v ** OSZCP (computeOverflow v1 v2 v) (msb v) (v == #0) carry (lsb v))).
Proof. do_instrrule_triple. Qed.

(** Only succeed if we don't generate more than one goal. *)
Ltac basicADC :=
  rewrite /makeBOP;
  let R := (lazymatch goal with
              | |- |-- basic ?p (@BOP ?d OP_ADC ?a) ?q => constr:(@ADC_rule d a)
            end) in
  first [ instrrules_basicapply R using (fun H => idtac)
        | instrrules_basicapply R ].

Lemma ADC_RI_rule_helper (r1:Reg) v1 (v2:DWORD) o s z c p
: let: (carry, v) := eta_expand (adcB c v1 v2) in
  |-- (basic (r1~=v1 ** OSZCP o s z c p)
             (ADC r1, v2)
             (r1~=v ** OSZCP (computeOverflow v1 v2 v) (msb v)
                (v == #0) carry (lsb v))).
Proof. basicADC. Qed.

Lemma ADC_RI_rule (r1:Reg) v1 (v2:DWORD) carry v o s z c p
: adcB c v1 v2 = (carry, v) ->
  |-- (basic (r1~=v1 ** OSZCP o s z c p)
             (ADC r1, v2)
             (r1~=v ** OSZCP (computeOverflow v1 v2 v) (msb v)
                (v == #0) carry (lsb v))).
Proof.
  move => H. generalize (@ADC_RI_rule_helper r1 v1 v2 o s z c p).
  by rewrite H.
Qed.
