(** Lattice module types and implementations for dataflow analysis.

    A lattice provides the mathematical foundation for dataflow analysis:
    - bottom: the least element (no information)
    - top: the greatest element (all information)
    - join: least upper bound (combines information from branches)
    - meet: greatest lower bound (intersects information)

    The PowersetLattice models sets of strings, which is useful for
    analyses like reaching definitions, live variables, etc.
*)

module type LATTICE = sig
  type t

  val bottom : t
  val top : t
  val join : t -> t -> t
  val meet : t -> t -> t
  val equal : t -> t -> bool
  val to_string : t -> string
end

module StringSet = Set.Make (String)

module PowersetLattice : sig
  include LATTICE with type t = StringSet.t
  val universe : StringSet.t ref
end = struct
  type t = StringSet.t

  let universe = ref StringSet.empty

  let bottom : t = StringSet.empty
  let top : t = !universe

  let join (a : t) (b : t) : t =
    StringSet.union a b

  let meet (a : t) (b : t) : t =
    StringSet.inter a b

  let equal (a : t) (b : t) : bool =
    StringSet.equal a b

  let to_string (s : t) : string =
    let elems = StringSet.elements s in
    let inside = String.concat ", " elems in
    "{" ^ inside ^ "}"
<<<<<<< HEAD
end
=======
end
>>>>>>> 86023823cd33144221941d7118f817def1cd27fc
