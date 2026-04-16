(** CFG Construction Exercises. *)

open Shared_ast.Ast_types

(** Helper: partition a statement list around the first occurrence of a
    statement matching [pred]. Returns (before, matching_stmt, after).
    Raises [Not_found] if no statement matches. *)
let partition_around (pred : stmt -> bool) (stmts : stmt list) =
  let rec aux acc = function
    | [] -> raise Not_found
    | s :: rest when pred s -> (List.rev acc, s, rest)
    | s :: rest -> aux (s :: acc) rest
  in
  aux [] stmts

(** Check if a statement is an If node *)
let is_if = function
  | If _ -> true
  | _ -> false

(** Check if a statement is a While node *)
let is_while = function
  | While _ -> true
  | _ -> false

(** Build a CFG for straight-line (sequential) code.

      ENTRY --> B1 --> EXIT *)
let build_cfg_sequential (stmts : stmt list) : Cfg.cfg =
  let entry = Cfg.create_block "ENTRY" [] in
  let b1 = Cfg.create_block "B1" stmts in
  let exit_block = Cfg.create_block "EXIT" [] in
  let blocks = Cfg.StringMap.empty
    |> Cfg.StringMap.add "ENTRY" entry
    |> Cfg.StringMap.add "B1" b1
    |> Cfg.StringMap.add "EXIT" exit_block
  in
  let cfg : Cfg.cfg = { entry = "ENTRY"; exit_label = "EXIT"; blocks } in
  cfg
  |> fun c -> Cfg.add_edge c "ENTRY" "B1"
  |> fun c -> Cfg.add_edge c "B1" "EXIT"

(** Build a CFG for an if-else branch (diamond pattern).

           ENTRY
             |
           B_cond
           /    \
       B_then  B_else
           \    /
           B_join
             |
            EXIT *)
let build_cfg_ifelse (stmts : stmt list) : Cfg.cfg =
  let (pre_stmts, if_stmt, post_stmts) = partition_around is_if stmts in
  let (then_stmts, else_stmts) = match if_stmt with
    | If (_, t, e) -> (t, e)
    | _ -> failwith "unreachable"
  in
  let entry = Cfg.create_block "ENTRY" [] in
  let b_cond = Cfg.create_block "B_cond" pre_stmts in
  let b_then = Cfg.create_block "B_then" then_stmts in
  let b_else = Cfg.create_block "B_else" else_stmts in
  let b_join = Cfg.create_block "B_join" post_stmts in
  let exit_block = Cfg.create_block "EXIT" [] in
  let blocks = Cfg.StringMap.empty
    |> Cfg.StringMap.add "ENTRY" entry
    |> Cfg.StringMap.add "B_cond" b_cond
    |> Cfg.StringMap.add "B_then" b_then
    |> Cfg.StringMap.add "B_else" b_else
    |> Cfg.StringMap.add "B_join" b_join
    |> Cfg.StringMap.add "EXIT" exit_block
  in
  let cfg : Cfg.cfg = { entry = "ENTRY"; exit_label = "EXIT"; blocks } in
  cfg
  |> fun c -> Cfg.add_edge c "ENTRY" "B_cond"
  |> fun c -> Cfg.add_edge c "B_cond" "B_then"
  |> fun c -> Cfg.add_edge c "B_cond" "B_else"
  |> fun c -> Cfg.add_edge c "B_then" "B_join"
  |> fun c -> Cfg.add_edge c "B_else" "B_join"
  |> fun c -> Cfg.add_edge c "B_join" "EXIT"

(** Build a CFG for a while loop (with back edge).

       ENTRY
         |
       B_pre
         |
       B_cond  <---+
       /    \      |
    B_body   \     |
      |       \    |
      +--------+   |
               |
            B_post
               |
             EXIT *)
let build_cfg_while (stmts : stmt list) : Cfg.cfg =
  let (pre_stmts, while_stmt, post_stmts) = partition_around is_while stmts in
  let body_stmts = match while_stmt with
    | While (_, body) -> body
    | _ -> failwith "unreachable"
  in
  let entry = Cfg.create_block "ENTRY" [] in
  let b_pre = Cfg.create_block "B_pre" pre_stmts in
  let b_cond = Cfg.create_block "B_cond" [] in
  let b_body = Cfg.create_block "B_body" body_stmts in
  let b_post = Cfg.create_block "B_post" post_stmts in
  let exit_block = Cfg.create_block "EXIT" [] in
  let blocks = Cfg.StringMap.empty
    |> Cfg.StringMap.add "ENTRY" entry
    |> Cfg.StringMap.add "B_pre" b_pre
    |> Cfg.StringMap.add "B_cond" b_cond
    |> Cfg.StringMap.add "B_body" b_body
    |> Cfg.StringMap.add "B_post" b_post
    |> Cfg.StringMap.add "EXIT" exit_block
  in
  let cfg : Cfg.cfg = { entry = "ENTRY"; exit_label = "EXIT"; blocks } in
  cfg
  |> fun c -> Cfg.add_edge c "ENTRY" "B_pre"
  |> fun c -> Cfg.add_edge c "B_pre" "B_cond"
  |> fun c -> Cfg.add_edge c "B_cond" "B_body"
  |> fun c -> Cfg.add_edge c "B_cond" "B_post"
  |> fun c -> Cfg.add_edge c "B_body" "B_cond"
  |> fun c -> Cfg.add_edge c "B_post" "EXIT"
