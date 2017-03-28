type archimate_layer =
  BusinessLayer |
  ApplicationLayer |
  TechnologyLayer |
  MotivationLayer |
  StrategyLayer |
  Junction

type bendpoint = {
  start_x : float option;
  start_y : float option;
  end_x : float option;
  end_y : float option;
}

type bounds = { x : float option; y : float option; width : float; height : float }

type documentation = { lang : string option; content : string }

type property = {
  key : string;
  value : string option;
}

type color = {
  r : int; (*lt: 256 : gt: -1*)
  g : int; (*lt: 256 : gt: -1*)
  b : int; (*lt: 256 : gt: -1*)
  a : int; (*lt: 101 : gt: -1*)
}

(* let validate color =
  let module V = Validate in
    let w check = V.field_folder color check in
      V.of_list
        (Fields.fold ~init:[]
          ~r:(w V.validate_bound 0 256)
          ~g:(w V.validate_bound 0 256)
          ~b:(w V.validate_bound 0 256)
          ~a:(w V.validate_bound 0 100)
        )
 *)
type font = {
  name : string;
  size : int; (* gt: 0 *)
  style : string option;
}

type style = {
  text_alignment : int option;
  fill_color : color option;
  line_color : color option;
  font_color : color option;
  line_width : int option;
  font : font option;
}

type source_connection = {
  id : string;
  source : string;
  target : string;
  relationship : string option;
  name : string option;
  source_connection_type : string option;
  bendpoints : bendpoint list;
  documentation : documentation list;
  properties : property list;
  style : style option;
}

type child = {
  id : string;
  child_type : string;
  model : string option;
  name : string option;
  target_connections : string option;
  archimate_element : string option;
  bounds : bounds;
  children : child list;
  source_connections : source_connection list;
  documentation : documentation list;
  properties : property list;
  style : style option;
}

type diagram = {
  id : string;
  name : string;
  viewpoint : string option;
  documentation : documentation list;
  properties : property list;
  children : child list;
  (* element_references : string list; *)
  connection_router_type : int option;
  diagram_type : string option;
}

type element = {
  id : string;
  element_type : string option;
  layer : archimate_layer;
  label : string option;
  documentation : documentation list;
  properties : property list;
}

type relationship = {
  id : string;
  relationship_type : string;
  source : string;
  target : string;
  name : string option;
  documentation : documentation list;
  properties : property list;
}

type folder = {
  id : string;
  name : string;
  folder_type : string option;
  items : string list;
  documentation : documentation list;
  properties : property list;
  folders : folder list;
}

type archimate_version = ArchiMate2_1 | ArchiMate3_0 | None

type model = {
  id : string;
  version : archimate_version;
  name : string;
  documentation : documentation list;
  properties : property list;
  elements : element list;
  folders : folder list;
  relationships : relationship list;
  diagrams : diagram list;
}

(* Tree type for XML parsing *)
type tree =
    Data of string |
    Model of model |
    Documentation of documentation |
    Folder of folder * tree list |
    Element of element |
    Relationship of relationship |
    Diagram of diagram |
    Child of child |
    Bounds of bounds |
    Source_connection of source_connection |
    Style of style |
    Bendpoint of bendpoint |
    Property of property |
    Unknown of string


let is_bendpoint a =
  match a with
  | Bendpoint _ -> true
  | _ -> false

let to_bendpoint bv =
  match bv with
  | Bendpoint b -> b
  | _ -> invalid_arg "Expected only bendpoint values"

let is_bounds a =
  match a with
  | Bounds _ -> true
  | _ -> false

let to_bounds bv =
  match bv with
  | Bounds b -> b
  | _ -> invalid_arg "Expected only bounds values"

let is_child a =
  match a with
  | Child _ -> true
  | _ -> false

let to_child a =
  match a with
  | Child c -> c
  | _ -> invalid_arg "Expected only child values"

let is_diagram a =
  match a with
  | Diagram _ -> true
  | _ -> false

let to_diagram n =
  match n with
  | Diagram d -> d
  | _ -> invalid_arg "Expected only diagram values"

let is_documentation a =
  match a with
  | Documentation _ -> true
  | _ -> false

let to_documentation a =
  match a with
  |  Documentation d -> d
  | _ -> invalid_arg "Expected only documentation values"

let is_element a =
  match a with
  | Element _ -> true
  | _ -> false

let to_element a =
  match a with
  | Element b -> b
  | _ -> invalid_arg "Expected only element values"

let is_folder a =
  match a with
  | Folder _ -> true
  | _ -> false

let to_folder a =
  match a with
  | Folder (b, c) -> b
  | _ -> invalid_arg "Expected only folder values"

let filter_folders childs =
  List.filter is_folder childs

let filter_folder_recs childs =
  filter_folders childs |> List.map to_folder

let is_property a =
  match a with
  | Property _ -> true
  | _ -> false

let to_property a =
  match a with
  | Property p -> p
  | _ -> invalid_arg "Expected only property values"

let is_relationship a =
  match a with
  | Relationship _ -> true
  | _ -> false

let to_relationship a =
  match a with
  | Relationship b -> b
  | _ -> invalid_arg "Expected only relationship values"

let is_source_connection a =
  match a with
  | Source_connection _ -> true
  | _ -> false

let to_source_connection bv =
  match bv with
  | Source_connection b -> b
  | _ -> invalid_arg "Expected only source_connection values"

let is_style a =
  match a with
  | Style _ -> true
  | _ -> false

let to_style a =
  match a with
  | Style b -> b
  | _ -> invalid_arg "Expected only style values"

(* Return the string content of Data nodes in a list of children *)
let data_child_content childs =
  let find_data_item a =
    match a with
    | Data _ -> true
    | _ -> false
  in
  try
    let data_item = List.find find_data_item childs in
    let content =
      match data_item with
      | Data s -> s
      | _ -> ""
    in
    content
  with Not_found ->
    ""

let find_all_nodes is_kind to_kind childs =
  List.filter is_kind childs |> List.map to_kind

let find_node is_kind to_kind childs =
  List.find is_kind childs |> to_kind

let find_optional_node is_kind to_kind childs =
  try
    Some (find_node is_kind to_kind childs)
  with Not_found ->
    None

let is_folder_item a =
  match a with
  | Element _
  | Relationship _
  | Diagram _ -> true
  | _ -> false

let id_for_tree_node a =
  match a with
  | Element e -> e.id
  | Relationship r -> r.id
  | Diagram d -> d.id
  | Model m -> m.id
  | Folder (f, c) -> f.id
  | Child c -> c.id
  | Source_connection s -> s.id
  | _ -> invalid_arg "Expected arg to have an id"

let folder_items childs =
  List.filter is_folder_item childs |>
  List.map id_for_tree_node

let rec find_all_in_folder is_kind to_kind folderv =
  match folderv with
  | Folder (f, c) ->
    let immediate_children = find_all_nodes is_kind to_kind c in
    let child_folders = filter_folders c in
    let folder_children =
      List.map (find_all_in_folder is_kind to_kind) child_folders |> List.concat
    in
    let all_children = [immediate_children; folder_children] in
    List.concat all_children
  | _ -> invalid_arg "Expected a Folder"

let find_all_in_folders is_kind to_kind folders =
  List.map (find_all_in_folder is_kind to_kind) folders |> List.concat

