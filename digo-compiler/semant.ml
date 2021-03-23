(* Semantic checking for the Digo compiler *)

open Ast

module StringMap = Map.Make(String)


let check (functions) =

  (* Verify a list of bindings has no void types or duplicate names *)
  

  (* Collect function declarations for built-in functions: no bodies.
    The built-in fucntions in digo are: append, len, gather.
    To do: change type of these built-in fucntion after defining them in ast
    To fix: parser directly gives error: "Fatal error: exception Stdlib.Parsing.Parse_error"
  *)
  let built_in_decls = 
    let add_bind map (name, ty) = StringMap.add name {
      ann = FuncNormal; 
      fname = name;
      typ = [];
      formals = [];
      body = [] } map
    in List.fold_left add_bind StringMap.empty [ ("append", IntegerType);
			                         ("len", IntegerType);
			                         ("gather", IntegerType)]
  in

  (* 
    This part is 
    1. Add function name to symbol table 
    2. Check for duplciate function naming and naming same with built-in functions. 
  *)
  let add_func map fd = 
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "duplicate function " ^ fd.fname
    and make_err er = raise (Failure er)
    and n = fd.fname (* Name of the function *)
    in match fd with (* No duplicate functions or redefinitions of built-ins *)
         _ when StringMap.mem n built_in_decls -> make_err built_in_err
       | _ when StringMap.mem n map -> make_err dup_err  
       | _ ->  StringMap.add n fd map 
  in
  
  (* This part is
    1. Collect all function names into one symbol table
  *)
  let function_decls = List.fold_left add_func built_in_decls functions
  (* pass here *)
  in

  (* Find_func finds a function from our symbol table. It can be used:
    1. check if every program main/master function
    2. check if function existed for function call
  *)
  let find_func s = 
    try StringMap.find s function_decls
    with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in

  let _ = find_func "main" in (* Ensure "main" is defined *)

  let check_function func =
    let report_duplicate exceptf list =
      let rec helper = function
          n1 :: n2 :: _ when n1 = n2 -> raise (Failure (exceptf n1))
        | _ :: t -> helper t
        | [] -> ()
      in helper (List.sort compare list)
    in report_duplicate (fun n -> "duplicate formal " ^ n ^ " in " ^ func.fname)
    (List.map fst func.formals);

  in (List.map check_function functions)
;;

let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.functions Scanner.tokenize lexbuf in
  check ast
