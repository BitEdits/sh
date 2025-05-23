open Parser
open Lexing
open Ast

type content = exp list
type file = string * content

let parseErr f lexbuf filename =
  try f Lexer.token lexbuf
  with Parser.Error ->
    raise (Error.Parser (lexbuf.lex_curr_p.pos_lnum, lexeme lexbuf, filename))

let lex filename =
  let chan = open_in filename in
  let lexbuf = Lexing.from_channel chan in
  Printf.printf "Lexing “%s”.\n" filename;
  try while true do
    let tok = Lexer.token lexbuf in
    if tok = Parser.EOF then raise End_of_file
    else print_string (Token.tokenToString tok ^ " ")
  done with End_of_file -> close_in chan;
  print_newline ()

let parse filename =
  let chan = open_in filename in
  Printf.printf "Parsing “%s”.\n" filename;
  Error.handleErrors
    (fun chan ->
      let lexbuf = Lexing.from_channel chan in
      let file = parseErr Parser.program lexbuf filename in
      print_endline (string_of_exp file))
    chan ()
