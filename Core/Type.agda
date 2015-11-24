module STLC.Core.Type where

open import STLC.Lib.Prelude

infixr 6 _⇒_
infixr 9 _∘ˢ_

data Type n : Set where
  Var : Fin n -> Type n
  _⇒_ : Type n -> Type n -> Type n

Type⁽⁾ : Set
Type⁽⁾ = Type 0

ftv-all : ∀ {n} -> Type n -> List (Fin n)
ftv-all (Var i) = i ∷ []
ftv-all (σ ⇒ τ) = ftv-all σ ++ ftv-all τ

ftv : ∀ {n} -> Type n -> List (Fin n)
ftv = nub ∘ ftv-all

Subst : ℕ -> ℕ -> Set
Subst n m = Fin n -> Type m

-- Make `Type' an instance of `IMonad' and `REWRITE' by the monad laws?
apply : ∀ {n m} -> Subst n m -> Type n -> Type m
apply Ψ (Var i) = Ψ i
apply Ψ (σ ⇒ τ) = apply Ψ σ ⇒ apply Ψ τ

_∘ˢ_ : ∀ {n m p} -> Subst m p -> Subst n m -> Subst n p
Φ ∘ˢ Ψ = apply Φ ∘ Ψ

wkᵗ : ∀ {m n} -> Type n -> Type (n + m)
wkᵗ = apply (Var ∘ inject+ _)

renᵗ : ∀ {n} m -> Type n -> Type (m + n)
renᵗ m = apply (Var ∘ raise m)

[_/_] : ∀ {n} -> Fin n -> Type n -> Fin n -> Type n
[ i / σ ] j = drec (const σ) (const (Var j)) (i ≟ j)

thickenˢ : ∀ {n} -> (σ : Type n) -> Subst n (length (ftv σ))
thickenˢ σ = λ i -> maybe Var undefined (lookup-for i (map swap (enumerate (ftv σ))))
  where postulate undefined : _
