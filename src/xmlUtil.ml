module Id_map = Map.Make(String)

(** Returns true if xdata has an id attribute *)
let has_id xdata =
  match xdata with
  | Xml.PCData pc -> false
  | Xml.Element el ->
    List.exists (fun p -> let (attr, _) = p in attr = "id") (Xml.attribs xdata);;

(** Returns true if xdata has an attribute attr_name *)
let has_attr xdata attr_name =
  match xdata with
  | Xml.PCData pc -> false
  | Xml.Element el ->
    List.exists (fun p -> let (attr, _) = p in attr = attr_name) (Xml.attribs xdata);;

(** Returns the value of an attribute in the attrs list with a given name *)
let attr_val attrs name =
  try
    let (_, aval) = List.find (fun p -> let (attr, _) = p in attr = name) attrs in
    aval;
  with Not_found ->
    "";;

(** Element identity gives us a way to unique way to talk about the element_identity *)
let element_identity xdata =
  match xdata with
  | Xml.PCData _ -> "None"
  | Xml.Element el ->
    let (tag, attrs, _) = el in
    let xsi_type = attr_val attrs "xsi:type" in
    let name = attr_val attrs "name" in
    String.concat "|" (
      List.filter (fun p -> String.length p > 0) [tag; xsi_type; name]);;

(** Returns a map of elements keyed by the id *)
let rec make_id_map id_map xdata =
  Printf.printf "Element Identity: %s\n" (element_identity xdata);
  match xdata with
  | Xml.PCData pc -> id_map
  | Xml.Element el ->
    Xml.fold make_id_map (
      if (has_id xdata) then
        (Id_map.add (Xml.attrib xdata "id") xdata id_map)
      else
        id_map) xdata;;

let rec attrib_val xdata attr_names =
  match xdata with
  | Xml.PCData pc -> ""
  | Xml.Element el ->
    (
      let _, el_attrs, _ = el in
      match attr_names with
      | [] -> ""
      | hd :: tl ->
        let find_attr_name attr_tuple =
          let attr, attr_val = attr_tuple in
          attr = hd
        in
        try
          let _, found_val = List.find find_attr_name el_attrs in
          found_val
        with Not_found ->
          attrib_val xdata tl
    )

(* let rec by_id (id : string) (xdata : Xml.xml) : Xml.xml =
  let find_func xdata =
    id = attr_val xdata "id" in

    match xdata with
    | Xml.PCData pc -> ""
    | Xml.Element el ->

  if id = attr_val xdata "id" then
    xdata
  else
    List.find find_func (Xml.children xdata);
 *)