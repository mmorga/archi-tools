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

let map_attributes attrs =
  let add_attr_map attr m =
    let name, value = attr in
    AttributeMap.add name value m
  in
  List.fold_right add_attr_map attrs AttributeMap.empty

let has_type key v =
  key == ("", "type")

let key_exists key k v =
  k == ("", key)

let fetch_ns ns key m =
  try
    AttributeMap.find (ns, key) m
  with Not_found ->
    Format.fprintf Format.std_formatter "Unable to find attribute '%s:%s' in attribute map" ns key;
    raise Not_found

let fetch key m =
  fetch_ns "" key m

let fetch_with_default key default m =
  match AttributeMap.exists (key_exists key) m with
  | true -> fetch key m
  | false -> default

let fetch_optional key m =
  match AttributeMap.exists (key_exists key) m with
  | true -> Some (fetch key m)
  | false -> None

let fetch_optional_float key m =
  match fetch_optional key m with
  | Some s -> Some (float_of_string s)
  | None -> None

let fetch_optional_int key m =
  match fetch_optional key m with
  | Some s -> Some (int_of_string s)
  | None -> None

let fetch_float key m =
  float_of_string (fetch key m)
