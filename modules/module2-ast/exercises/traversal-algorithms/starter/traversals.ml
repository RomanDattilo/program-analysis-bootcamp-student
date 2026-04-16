(* traversals.ml - AST traversal algorithms exercise.
   Implement three classic tree traversal strategies on the AST:
   pre-order (depth-first), post-order (depth-first), and
   breadth-first (level-order).

   Each function walks a list of statements and collects a string label
   for every node visited. Labels should look like:
     Statements: "Assign", "If", "While", "Return", "Print", "Block"
     Expressions: "IntLit(3)", "BoolLit(true)", "Var(x)", "BinOp(+)",
                  "UnaryOp(-)", "Call(f)"
*)

open Shared_ast.Ast_types

let string_of_op op =
  match op with
  | Add -> "+" | Sub -> "-" | Mul -> "*" | Div -> "/"
  | Eq -> "==" | Neq -> "!=" | Lt -> "<" | Gt -> ">"
  | Le -> "<=" | Ge -> ">=" | And -> "&&" | Or -> "||"

let string_of_uop uop =
  match uop with Neg -> "-" | Not -> "!"

let label_of_expr (e : expr) : string =
  match e with
  | IntLit n          -> "IntLit(" ^ string_of_int n ^ ")"
  | BoolLit b         -> "BoolLit(" ^ string_of_bool b ^ ")"
  | Var s             -> "Var(" ^ s ^ ")"
  | BinOp (op, _, _)  -> "BinOp(" ^ string_of_op op ^ ")"
  | UnaryOp (op, _)   -> "UnaryOp(" ^ string_of_uop op ^ ")"
  | Call (name, _)    -> "Call(" ^ name ^ ")"

let label_of_stmt (s : stmt) : string =
  match s with
  | Assign _  -> "Assign"
  | If _      -> "If"
  | While _   -> "While"
  | Return _  -> "Return"
  | Print _   -> "Print"
  | Block _   -> "Block"

let rec pre_order_expr (e : expr) : string list =
  let lbl = [label_of_expr e] in
  match e with
  | IntLit _ | BoolLit _ | Var _ -> lbl
  | BinOp (_, e1, e2) -> lbl @ pre_order_expr e1 @ pre_order_expr e2
  | UnaryOp (_, e1)   -> lbl @ pre_order_expr e1
  | Call (_, args)    -> lbl @ List.concat_map pre_order_expr args

and pre_order_stmt (s : stmt) : string list =
  let lbl = [label_of_stmt s] in
  match s with
  | Assign (_, e)                 -> lbl @ pre_order_expr e
  | If (cond, then_b, else_b)     ->
      lbl @ pre_order_expr cond
          @ pre_order_stmts then_b
          @ pre_order_stmts else_b
  | While (cond, body)            -> lbl @ pre_order_expr cond @ pre_order_stmts body
  | Return None                   -> lbl
  | Return (Some e)               -> lbl @ pre_order_expr e
  | Print exprs                   -> lbl @ List.concat_map pre_order_expr exprs
  | Block stmts                   -> lbl @ pre_order_stmts stmts

and pre_order_stmts (stmts : stmt list) : string list =
  List.concat_map pre_order_stmt stmts

let pre_order (stmts : stmt list) : string list =
  pre_order_stmts stmts

let rec post_order_expr (e : expr) : string list =
  let lbl = [label_of_expr e] in
  match e with
  | IntLit _ | BoolLit _ | Var _ -> lbl
  | BinOp (_, e1, e2) -> post_order_expr e1 @ post_order_expr e2 @ lbl
  | UnaryOp (_, e1)   -> post_order_expr e1 @ lbl
  | Call (_, args)    -> List.concat_map post_order_expr args @ lbl

and post_order_stmt (s : stmt) : string list =
  let lbl = [label_of_stmt s] in
  match s with
  | Assign (_, e)                 -> post_order_expr e @ lbl
  | If (cond, then_b, else_b)     ->
      post_order_expr cond
      @ post_order_stmts then_b
      @ post_order_stmts else_b
      @ lbl
  | While (cond, body)            -> post_order_expr cond @ post_order_stmts body @ lbl
  | Return None                   -> lbl
  | Return (Some e)               -> post_order_expr e @ lbl
  | Print exprs                   -> List.concat_map post_order_expr exprs @ lbl
  | Block stmts                   -> post_order_stmts stmts @ lbl

and post_order_stmts (stmts : stmt list) : string list =
  List.concat_map post_order_stmt stmts

let post_order (stmts : stmt list) : string list =
  post_order_stmts stmts

type node = Stmt_node of stmt | Expr_node of expr

let children_of_node (n : node) : node list =
  match n with
  | Expr_node e -> (match e with
    | IntLit _ | BoolLit _ | Var _ -> []
    | BinOp (_, e1, e2)  -> [Expr_node e1; Expr_node e2]
    | UnaryOp (_, e1)    -> [Expr_node e1]
    | Call (_, args)     -> List.map (fun a -> Expr_node a) args)
  | Stmt_node s -> (match s with
    | Assign (_, e)             -> [Expr_node e]
    | If (cond, then_b, else_b) ->
        [Expr_node cond]
        @ List.map (fun s -> Stmt_node s) then_b
        @ List.map (fun s -> Stmt_node s) else_b
    | While (cond, body)        ->
        Expr_node cond :: List.map (fun s -> Stmt_node s) body
    | Return None               -> []
    | Return (Some e)           -> [Expr_node e]
    | Print exprs               -> List.map (fun e -> Expr_node e) exprs
    | Block stmts               -> List.map (fun s -> Stmt_node s) stmts)

let label_of_node (n : node) : string =
  match n with
  | Expr_node e -> label_of_expr e
  | Stmt_node s -> label_of_stmt s

let bfs (stmts : stmt list) : string list =
  let q = Queue.create () in
  List.iter (fun s -> Queue.push (Stmt_node s) q) stmts;
  let result = ref [] in
  while not (Queue.is_empty q) do
    let node = Queue.pop q in
    result := !result @ [label_of_node node];
    List.iter (fun child -> Queue.push child q) (children_of_node node)
  done;
  !result