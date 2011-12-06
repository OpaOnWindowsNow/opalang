(*
    Copyright © 2011 MLstate

    This file is part of OPA.

    OPA is free software: you can redistribute it and/or modify it under the
    terms of the GNU Affero General Public License as published by the Free
    Software Foundation, either version 3 of the License, or (at your option)
    any later version.

    OPA is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
    more details.

    You should have received a copy of the GNU Affero General Public License
    along with OPA. If not, see <http://www.gnu.org/licenses/>.
*)
(**
 convert linux style shell command call to windows style

 the primary goal of this script is to call ocaml windows compiler in a unix environment (cygwin)


 ocamlc -c /home/toto/toto.ml => c:\ocamlms\bin\ocamlc.exe -c c:\cygwin\cygdrive\c\home\toto\toto.ml

 what seems to be filepath are converted using PathTransform
 it can add verbose options
 the behaviour can depend on the command (ocamlc,ocamldep ...) see behaviour definition


*)

(* a speedy port of a shell script => poor structure *)

open Printf

(* Env variable path transofrmation *)
let mlstatelibs =
  try
    "MLSTATELIBS=\"" ^ (PathTransform.string_to_windows (Sys.getenv "MLSTATELIBS")) ^ "\" "
  with _ -> ""

let env_args = mlstatelibs

let opageneral = try Sys.getenv "OPAGENERAL" with _ -> ""
let add_verbose=true;;

let arg i = Sys.argv.(i);;

let logdir=Filename.dirname (arg 0);;

let logfile = open_out_gen [Open_append; Open_text ] (7*64+7*8+7) (logdir ^ "/windows_gate.log") (*stdout*);;
let debug mess = fprintf  logfile "%s\n" mess; flush logfile;;

let _ = debug "--------------------------" ;;
let _ = debug (sprintf "%1.3f" (Sys.time()));;

let command=(arg 1)

let wd = Sys.getcwd ()
let opadir = opageneral ^ "/_build/opa/"
let windir = try (Sys.getenv "OCAML_TARGET_DIR")^"/bin/" with _ -> "/cygdrive/c/ocamlms/bin/"

let prefix pref s =
 let res = Str.string_match (Str.regexp pref) s 0 in (*Printf.fprintf stderr "Prefix %s %b \n" pref res;*)  res

let match_reg s preflist ~default =
  match List.fold_left (fun acc (pref,answer)-> if acc = None && (prefix pref s ) then Some (Lazy.force answer) else acc) None preflist with
  | Some s -> s
  | _ -> Lazy.force default



(** behaviour : containg specific command transformation
    verbose : the form of verbose option
    accept_relative : do we need to translate relative path ?
    comdir,ext : where is the executable ? which exetension ?
    _o_force_path : does -o implies a path argument
 *)
type behaviour = {
  verbose : string ;
  accept_relative : bool ;
  comdir : string ;
  ext : string ;
  _o_force_path : bool ;
}

let behaviour = {
  verbose = "" ;
  accept_relative = false ;
  comdir = "" ; ext = "" ;
  _o_force_path = true ;
}

let string_map f s = let s = String.copy s in for i=0 to String.length s -1 do s.[i] <- f s.[i] done; s
let string_str_map f s = String.concat "" (Array.to_list (Array.init (String.length s) (fun i-> f s.[i])))

let behaviour  =
   let bcaml = { behaviour with comdir=windir ; ext = ".exe" } in
   let bopa = { behaviour with comdir=opadir ; ext = ".native" } in
   let dcaml = lazy bcaml in
   let d = lazy behaviour in
   let d_o_no_forcepath = lazy {behaviour with  _o_force_path = false} in
   match_reg command [
   (* ocamlbuild doesn t like ocaml dep generated files containing windows path *)
   "ocamldep", lazy {bcaml with accept_relative=true};
   "ocamlfind",dcaml;
   "ocamllex", dcaml;
   "ocamldoc", dcaml;
   ".*bslregister.*",d_o_no_forcepath ;
   ".*trx_ocaml.*",d;
   "ocaml"    , if add_verbose then lazy {bcaml with verbose = "-verbose"} else dcaml;
   "main", lazy bopa
] ~default: (lazy (Printf.fprintf stderr "Unknown command %s in opageneral/ms_windows/windows_gate\n" command; (*exit 1*) Lazy.force d) )

let anti_slash_char n = String.make n '\\'
let escaped_anti_slash_char n = String.make (n*2) '\\'

let anti_slash s = string_str_map (function '/' -> escaped_anti_slash_char 1  | c -> String.make 1 c) s

let no_endline s = string_map (function '\r' | '\n' -> ' ' | c -> c) s

let simple_win_path path = if behaviour.accept_relative && PathTransform.is_relative path then anti_slash path else PathTransform.string_to_windows path
(*   let npath =
   match_reg path [
   "/"  , lazy ("C:/cygwin"^path);
   "../", lazy (assert false);
   "./", lazy (assert false);
   ] ~default:(lazy path)
   in anti_slash npath
*)
(*let file_exists f = try Unix.stat f; true with _ -> false*)

(* # take an potential path, and an indicator to assume that it is a path (need to be "YES") *)
let windows_path arg forcepath =
  let dquote = "\"" in
  let narg =
   if Sys.file_exists arg || forcepath then
    let narg = simple_win_path arg in
    narg
   else
    if String.contains arg ' ' then dquote ^ arg ^ dquote else arg
  in
   (* doubler les backslash *)
    if arg <> narg then debug (sprintf "%s => %s" arg narg);
    narg

let rem_2_char s =  try String.sub s 2 (String.length s - 2) with _ -> "";;

let project_argument arg prevarg =
    let arg = no_endline arg in
    match_reg arg [
    "-L/", lazy (debug "PROJ -L";
                 let arg = rem_2_char arg in
                 if arg <> "" then sprintf "-L\"%s\"" (windows_path arg true)
                 else arg);
    "-I/", lazy (debug "PROJ -I";
                 let arg = rem_2_char arg in
                 if arg <> "" then sprintf "-I %s" (windows_path arg true)
                 else arg);
    "/", lazy ( debug "PROJ /";
		if prevarg = "-I" || prevarg = "-pp" then (debug "PROJ -I or -pp"; windows_path arg true)
		else arg);
    ] ~default:( lazy (if prevarg = "-o" && behaviour._o_force_path then (debug "PROJ -o"; windows_path arg true)
                else windows_path arg false)
                )


let args = String.concat " " (Array.to_list Sys.argv)
;;debug (sprintf "%s %s" command (String.concat " " (Array.to_list Sys.argv)));;

let nargs = Array.init (Array.length Sys.argv -1) (fun i -> (project_argument (arg (i+1)) (arg i)))
let nargs = try String.concat " " (List.tl (Array.to_list nargs)) with _ -> ""

;;debug (sprintf "%s %s" command args)

let ncom = (sprintf "%s%s%s %s " behaviour.comdir command behaviour.ext behaviour.verbose)^nargs

;;debug ncom
;;debug (sprintf "%1.3f" (Sys.time()))
;;exit (Sys.command(env_args ^ ncom))
