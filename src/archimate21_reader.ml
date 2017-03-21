(* module AttributeMap = Map.Make(String) *)

module OrderedXmlName =
struct type t = Xmlm.name
  let compare a b =
    let a0, a1 = a in
    let b0, b1 = b in
    let nscmp = String.compare a0 b0 in
    match nscmp with
    | 0 -> String.compare a1 b1
    | _ -> nscmp
end
module AttributeMap = Map.Make(OrderedXmlName)


let add_attr_map attr m =
  let name, value = attr in
  AttributeMap.add name value m

let error () = invalid_arg "parse error"

(* accept the given signal from input or throw an error *)
let accept s i = if Xmlm.input i = s then () else error ()


let in_model model_tag i =
  let tag_name, attrs = model_tag in
  let empty_attribute_map = AttributeMap.empty in
  let attribute_map = List.fold_right add_attr_map attrs empty_attribute_map in
  Model.make (attribute_map.choose "id") (attribute_map "version") (attribute_map "name")

let in_archimate21_model src =
  let i = Xmlm.make_input ~strip:true src in
  accept (`Dtd None) i;
  let signal = Xmlm.input i in
  match signal with
  | `El_start model_tag -> in_model model_tag i
  | _ -> error()

(*   { *)
(*   id : string; *)
(*   version : archimate_version; *)
(*   name : string; *)
(*   documentation : documentation list; *)
(*   properties : property list; *)
(*   elements : element list; *)
(*   folders : folder list; *)
(*   relationships : relationship list; *)
(*   diagrams : diagram list; *)
(* } *)

(* type w3c_bureaucrat = { *)
(*     name : string; *)
(*     surname : string; *)
(*     honest : bool; *)
(*     obfuscation_level : float; *)
(*     trs : string list; } *)

(* let in_w3c_bureaucrats src = *)
(*   let i = Xmlm.make_input ~strip:true src in *)
(*   let tag n = ("", n), [] in *)
(*   let error () = invalid_arg "parse error" in *)
(*   let accept s i = if Xmlm.input i = s then () else error () in *)
(*   let rec i_seq el acc i = match Xmlm.peek i with *)
(*   | `El_start _ -> i_seq el ((el i) :: acc) i *)
(*   | `El_end -> List.rev acc *)
(*   | _ -> error () *)
(*   in *)
(*   let i_el n i = *)
(*     accept (`El_start (tag n)) i; *)
(*     let d = match Xmlm.peek i with *)
(*     | `Data d -> ignore (Xmlm.input i); d *)
(*     | `El_end -> "" *)
(*     | _ -> error () *)
(*     in *)
(*     accept (`El_end) i; *)
(*     d *)
(*   in *)
(*   let i_bureaucrat i = *)
(*     try *)
(*       accept (`El_start (tag "bureaucrat")) i; *)
(*       let name = i_el "name" i in *)
(*       let surname = i_el "surname" i in *)
(*       let honest = match Xmlm.peek i with *)
(*       | `El_start (("", "honest"), []) -> ignore (i_el "honest" i); true *)
(*       | _ -> false *)
(*       in *)
(*       let obf = float_of_string (i_el "obfuscation_level" i) in *)
(*       let trs = i_seq (i_el "tr") [] i in *)
(*       accept (`El_end) i; *)
(*       { name = name; surname = surname; honest = honest; *)
(*         obfuscation_level = obf; trs = trs } *)
(*     with *)
(*     | Failure _ -> error () (\* float_of_string *\) *)
(*   in *)
(*   accept (`Dtd None) i; *)
(*   accept (`El_start (tag "list")) i; *)
(*   let bl = i_seq i_bureaucrat [] i in *)
(*   accept (`El_end) i; *)
(*   if not (Xmlm.eoi i) then invalid_arg "more than one document"; *)
(*   bl *)

(* let out_w3c_bureaucrats dst bl = *)
(*   let tag n = ("", n), [] in *)
(*   let o = Xmlm.make_output ~nl:true ~indent:(Some 2) dst in *)
(*   let out = Xmlm.output o in *)
(*   let o_el n d = *)
(*     out (`El_start (tag n)); *)
(*     if d <> "" then out (`Data d); *)
(*     out `El_end *)
(*   in *)
(*   let o_bureaucrat b = *)
(*     out (`El_start (tag "bureaucrat")); *)
(*     o_el "name" b.name; *)
(*     o_el "surname" b.surname; *)
(*     if b.honest then o_el "honest" ""; *)
(*     o_el "obfuscation_level" (string_of_float b.obfuscation_level); *)
(*     List.iter (o_el "tr") b.trs; *)
(*     out `El_end *)
(*   in *)
(*   out (`Dtd None); *)
(*   out (`El_start (tag "list")); *)
(*   List.iter o_bureaucrat bl; *)
(*   out (`El_end) *)
