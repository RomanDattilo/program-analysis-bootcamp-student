(** Generic iterative dataflow analysis solver.

    This module implements the classic worklist-based fixpoint algorithm
    that underlies most dataflow analyses (reaching definitions, live
    variables, available expressions, etc.).
*)

type direction = Forward | Backward

type 'a analysis = {
  direction : direction;
  init : 'a;
  merge : 'a -> 'a -> 'a;
  transfer : string -> 'a -> 'a;
  equal : 'a -> 'a -> bool;
}

module StringMap = Map.Make (String)

let solve (analysis : 'a analysis)
    (cfg : (string * string list * string list) list)
    : (string * 'a * 'a) list =
  (* Initialize IN and OUT for every block *)
  let init_map =
    List.fold_left
      (fun m (label, _, _) -> StringMap.add label analysis.init m)
      StringMap.empty
      cfg
  in
  let in_map  = ref init_map in
  let out_map = ref init_map in

  let get map key =
    match StringMap.find_opt key map with
    | Some v -> v
    | None -> analysis.init
  in

  let changed = ref true in
  while !changed do
    changed := false;

    List.iter
      (fun (label, preds, succs) ->
        let old_in  = get !in_map label in
        let old_out = get !out_map label in

        let new_in, new_out =
          match analysis.direction with
          | Forward ->
              let in_b =
                List.fold_left
                  (fun acc p -> analysis.merge acc (get !out_map p))
                  analysis.init
                  preds
              in
              let out_b = analysis.transfer label in_b in
              (in_b, out_b)

          | Backward ->
              let out_b =
                List.fold_left
                  (fun acc s -> analysis.merge acc (get !in_map s))
                  analysis.init
                  succs
              in
              let in_b = analysis.transfer label out_b in
              (in_b, out_b)
        in

        if not (analysis.equal old_in new_in) then begin
          changed := true;
          in_map := StringMap.add label new_in !in_map
        end;

        if not (analysis.equal old_out new_out) then begin
          changed := true;
          out_map := StringMap.add label new_out !out_map
        end)
      cfg
  done;

  List.map
    (fun (label, _, _) ->
      (label, get !in_map label, get !out_map label))
<<<<<<< HEAD
    cfg
=======
    cfg
>>>>>>> 86023823cd33144221941d7118f817def1cd27fc
