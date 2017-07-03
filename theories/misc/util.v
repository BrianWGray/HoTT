Require Import
  HoTTClasses.interfaces.canonical_names.

Definition ap2 `(f : A -> B -> C) {x1 x2 y1 y2}:
  x1 = x2 -> y1 = y2 -> f x1 y1 = f x2 y2.
Proof.
intros H1 H2;destruct H1,H2;reflexivity.
Defined.

Section pointwise_dependent_relation.
  Context A (B: A -> Type) (R: forall a, relation (B a)).

  Definition pointwise_dependent_relation: relation (forall a, B a) :=
    λ f f', forall a, R _ (f a) (f' a).

  Global Instance pdr_equiv {_:forall a, Equivalence (R a)}
    : Equivalence pointwise_dependent_relation.
  Proof.
  split.
  - intros f a.
    apply reflexivity.
  - intros f g H a.
    apply symmetry;auto.
  - intros f g h H1 H2 a.
    transitivity (g a);auto.
  Qed.
End pointwise_dependent_relation.

Definition iffT (A B: Type): Type := prod (A -> B) (B -> A).

(* Class NonEmpty (A : Type) : Type := non_empty : inhabited A. *)
Class NonEmptyT (A : Type) : Type := non_emptyT : A.

Definition uncurry {A B C} (f: A -> B -> C) (p: A * B): C := f (fst p) (snd p).

Definition is_sole {T} (P: T -> Type) (x: T) : Type := P x /\ forall y, P y -> y = x.

Definition DN (T: Type): Type := (T -> Empty) -> Empty.
Class Stable P := stable: DN P -> P.
(* TODO: include useful things from corn/logic/Stability.v
   and move to separate file *)

Class Obvious (T : Type) := obvious: T.

Section obvious.
  Context (A B C: Type).

  Global Instance: Obvious (A -> A) := id.
  Global Instance: Obvious (Empty -> A) := Empty_rect _.
  Global Instance: Obvious (A -> A + B)%type := inl.
  Global Instance: Obvious (A -> B + A)%type := inr.
  Global Instance obvious_sum_src `{Obvious (A -> C)} `{Obvious (B -> C)}
    : Obvious (A+B -> C)%type.
  Proof.
    intros [?|?]; auto.
  Defined.

  Global Instance obvious_sum_dst_l `{Obvious (A -> B)}
    : Obvious (A -> B+C)%type.
  Proof.
    red;auto.
  Defined.

  Global Instance obvious_sum_dst_r `{Obvious (A -> B)}: Obvious (A -> C\/B).
  Proof.
    red;auto.
  Defined.
End obvious.

Lemma not_symmetry `{Symmetric A R} (x y: A): ~R x y -> ~R y x.
Proof.
auto.
Qed.
(* Also see Coq bug #2358.
   A totally different approach would be to define negated relations
   such as inequality as separate relations rather than notations,
   so that the existing [symmetry] will work for them.
   However, this most likely breaks other things. *)

Lemma iff_unit : forall P, P -> Unit <-> P.
Proof.
intros P p;split;auto.
Defined.

Lemma iff_empty : forall P, ~ P -> Empty <-> P.
Proof.
intros P n;split.
- apply obvious.
- exact n.
Defined.

Lemma biinduction_iff `{Biinduction R}
  (P1 : Type) (P2 : R -> Type) :
  (P1 <-> P2 0) -> (forall n, P2 n <-> P2 (1 + n)) -> forall n, P1 <-> P2 n.
Proof.
intros init ind.
apply biinduction.
- assumption.
- intros n. split.
  + intros X.
    apply (transitivity X).
    apply ind.
  + intros X.
    apply (transitivity X).
    apply symmetry. apply ind.
Qed.

(* Isn't this in the stdlib? *)
Definition is_Some `(x : option A) :=
  match x with
  | None => Empty
  | Some _ => Unit
  end.

Lemma is_Some_def `(x : option A) :
  is_Some x <-> exists y, x = Some y.
Proof.
unfold is_Some.
destruct x.
- apply iff_unit. exists a;reflexivity.
- apply iff_empty. intros [y H].
  change (@is_Some A None).
  apply transport with (Some y).
  + symmetry. assumption.
  + simpl. auto.
Qed.

Definition is_None `(x : option A) :=
  match x with
  | None => Unit
  | Some _ => Empty
  end.

Lemma is_None_def `(x : option A) :
  is_None x <-> x = None.
Proof.
unfold is_None. destruct x as [a|].
- apply iff_empty.
  intros H.
  change (is_None (Some a)).
  apply transport with None.
  + symmetry;assumption.
  + simpl;auto.
- apply iff_unit. reflexivity.
Qed.

Lemma None_ne_Some `(x : A) :
  ~ (None = Some x).
Proof.
intros e.
change (is_None (Some x)).
apply transport with None.
- assumption.
- simpl;auto.
Qed.

Fixpoint repeat {A:Type} (n:nat) (f : A -> A) (x : A) : A :=
  match n with
  | 0%nat => x
  | S k => f (repeat k f x)
  end.
