open Xmlm
open Printf
open Datamodel

let format_attr tag_attr =
  match tag_attr with ((_, local), value) -> local ^ "=" ^ value

let conditional_content depth s =
  let trimmed_s = String.trim s in
  if String.length trimmed_s = 0 then "" else (String.make (depth * 2) ' ') ^ trimmed_s ^ "\n"

let format_attrs attrs =
  let attr_str =
    List.map format_attr attrs
  in
  String.concat "," attr_str

let format_tag ns name attrs =
  let ns_str =
    if (String.length (String.trim ns)) = 0 then "" else ns ^ ":"
  in
    let attrs_str = format_attrs attrs
    in
      ns_str ^ name ^ "(" ^ attrs_str ^ ")"

let attr_val attrs name =
  match (List.find (fun a -> let ((ns, aname), value) = a in aname = name) attrs) with
  | _, value -> value

let parse_model i attrs depth =
  {
    id = (attr_val attrs "id");
    name = attr_val attrs "name";
    documentation = [];
    elements = [];
    properties = [];
    folders = [];
    relationships = [];
    diagrams = []
  }

let id ic oc =
  let i = Xmlm.make_input (`Channel ic) in
  let o = Xmlm.make_output (`Channel oc) in
  let rec pull i o depth =
    (* Xmlm.output o (Xmlm.peek i); *)
    print_string (match Xmlm.peek i with
        | `El_start ((ns, name), attrs) -> (conditional_content depth (format_tag ns name attrs))
        | `El_end -> ""
        | `Data content -> conditional_content depth content
        | `Dtd _ -> "");
    match Xmlm.input i with
    | `El_start ((ns, name), attrs) ->
      (match name with
            | "model" -> parse_model i attrs (depth + 1)
            | _ -> pull i o (depth + 1))
    | `El_end -> if depth = 1 then () else pull i o (depth - 1)
    | `Data content -> pull i o depth  (* this is the text node *)
    | `Dtd _ -> assert false
  in
  Xmlm.output o (Xmlm.input i); (* `Dtd *)
  pull i o 0;
  if not (Xmlm.eoi i) then invalid_arg "document not well-formed"


let file = "test/Archisurance.archimate"

let () =
  let ic = open_in file in
  id ic stdout
