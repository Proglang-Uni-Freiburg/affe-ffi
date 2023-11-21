{
open Parser
}

rule token = parse
  | [' ' '\t']     { token lexbuf }     (* skip blanks *)
  | '#' [^'\n']* '\n' 
  | '\n' { Lexing.new_line lexbuf ; token lexbuf }
  | '-'?[ '0'-'9' ]+ as x	{INT (int_of_string x)}
  | '"' ([^ '"']* as s) '"' { STRING s}
  | "extern" { EXTERN }
  | "Y" { YTOK }
  | "let" { LET }
  | "in" { IN }
  | "=" { EQUAL }
  | "fun" { FUN }
  | "rec" { REC }
  | "%" { PERCENT }
  | "->" { RIGHTARROW }
  | "<-" { LEFTARROW }
  | "-{" { DASHLACCO }
  | "<" { LESS }
  | "&!" { ANDBANG }
  | "&" { AND }
  | "_" { UNDERSCORE }
  | "}>" { RACCOGREATER }
  | '('	{ LPAREN }
  | ')'	{ RPAREN }
  | '{'	{ LACCO }
  | '}'	{ RACCO }
  | "[|"	{ LBRACKPIPE }
  | "|]"	{ PIPERBRACK }
  | "-" { MINUS }
  | "<" { LESS }
  | ">" { GREATER }
  | "+" { PLUS }
  | "*" { STAR }
  | "|" { BAR }
  | "/" { DIV }
  | "." { DOT }
  | "type" { TYPE }
  | "val" { VAL }
  | "with" { WITH }
  | "match" { MATCH None }
  | "match&" { MATCH (Some Immutable) }
  | "match&!" { MATCH (Some Mutable) }
  | "=>" { BIGRIGHTARROW }
  | "of" { OF }
  | "import" { IMPORT }
  | "for all" | "\\" { FORALL }
  | ":" { DOUBLECOLON }
  | "," { COMMA }
  | "un" { UN }
  | "aff" { AFF }
  | "lin" { LIN }
  | ';' { SEMI }
  | ";;"	{ SEMISEMI }
  | ('#' [^'\n']*)? eof { EOF }
  | "'" ( '_'? [ 'A'-'Z' 'a'-'z' '0'-'9' '_' '\'' ]+ as s)  { TYIDENT s }
  | ( '_'? [ 'a'-'z' ] [ 'A'-'Z' 'a'-'z' '0'-'9' '_' '\'' ]*) as s  { IDENT s }
  | ( '_'? ['A'-'Z'] [ 'A'-'Z' 'a'-'z' '0'-'9' '_' '\'' ]* '.'
      [ 'a'-'z' ] [ 'A'-'Z' 'a'-'z' '0'-'9' '_' '\'' ]*) as s { MIDENT s }
  | ( '_'? ['A'-'Z'] [ 'A'-'Z' 'a'-'z' '0'-'9' '_' '\'' ]* '.'
      [ 'A'-'Z' ] [ 'A'-'Z' 'a'-'z' '0'-'9' '_' '\'' ]*) as s { MUIDENT s }
  | ( '_'? [ 'A'-'Z' ] [ 'A'-'Z' 'a'-'z' '0'-'9' '_' '\'' ]*) as s  { UIDENT s }
  | "<|" { read_ocaml_inline (Buffer.create 16 ) lexbuf }

and read_ocaml_inline buffer = parse
  | "|>" { OCAML (Buffer.contents buffer) }
  | [^'\n'] as c { Buffer.add_char buffer c ; read_ocaml_inline buffer lexbuf }
  | '\n' { Buffer.add_char buffer '\n' ;
           Lexing.new_line lexbuf ;
           read_ocaml_inline buffer lexbuf }
