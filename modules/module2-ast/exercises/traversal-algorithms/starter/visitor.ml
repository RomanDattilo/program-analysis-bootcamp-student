(* visitor.ml - AST visitor pattern exercises. *)

open Shared_ast.Ast_types

let inc (key : string) (counts : (string * int) list) : (string * int) list =
  if List.mem_assoc key counts then
    List.map (fun (k, v) -> if k = key then (k, v + 1) else (k, v)) counts
  else
    counts @ [(key, 1)]

let rec count_expr (acc : (string * int) list) (e : expr) : (string * int) list =
  match e with
  | IntLit _  -> inc "IntLit" acc
  | BoolLit _ -> inc "BoolLit" acc
  | Var _     -> inc "Var" acc
  | BinOp (_, e1, e2) ->
      let acc = inc "BinOp" acc in
      count_expr (count_expr acc e1) e2
  | UnaryOp (_, e1) ->
      count_expr (inc "UnaryOp" acc) e1
  | Call (_, args) ->
      List.fold_left count_expr (inc "Call" acc) args

and count_stmt (acc : (string * int) list) (s : stmt) : (string * int) list =
  match s with
  | Assign (_, e)             -> count_expr (inc "Assign" acc) e
  | If (cond, then_b, else_b) ->
      let acc = inc "If" acc in
      let acc = count_expr acc cond in
      let acc = count_stmts acc then_b in
      count_stmts acc else_b
  | While (cond, body)        ->
      let acc = inc "While" acc in
      let acc = count_expr acc cond in
      count_stmts acc body
  | Return None               -> inc "Return" acc
  | Return (Some e)           -> count_expr (inc "Return" acc) e
  | Print exprs               -> List.fold_left count_expr (inc "Print" acc) exprs
  | Block stmts               -> count_stmts (inc "Block" acc) stmts

and count_stmts (acc : (string * int) list) (stmts : stmt list) : (string * int) list =
  List.fold_left count_stmt acc stmts

let count_nodes (stmts : stmt list) : (string * int) list =
  count_stmts [] stmts

let evaluate (e : expr) : int option =
  let rec eval e =
    match e with
    | IntLit n -> Some n
    | BinOp (op, e1, e2) ->
        Option.bind (eval e1) (fun v1 ->
        Option.bind (eval e2) (fun v2 ->
          match op with
          | Add -> Some (v1 + v2)
          | Sub -> Some (v1 - v2)
          | Mul -> Some (v1 * v2)
          | Div -> if v2 = 0 then None else Some (v1 / v2)
          | _   -> None))
    | UnaryOp (Neg, e1) ->
        Option.bind (eval e1) (fun v -> Some (-v))
    | _ -> None
  in
<<<<<<< HEAD
  eval e
=======
  eval e
>>>>>>> 86023823cd33144221941d7118f817def1cd27fc
