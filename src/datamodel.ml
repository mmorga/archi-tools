
type bendpoint = {
  start_x : float option;
  start_y : float option;
  end_x : float option;
  end_y : float option;
}
let empty_bendpoint =
  {
    start_x = None;
    start_y = None;
    end_x = None;
    end_y = None;
  }

type bounds = { x : float option; y : float option; width : float; height : float }
let empty_bounds =
  {
    x = None;
    y = None;
    width = 0.0;
    height = 0.0;
  }
 
type documentation = { lang : string option; content : string }
let empty_documentation =
  {
    lang = None;
    content = "";
  }

type property = {
  key : string;
  value : string option;
}
let empty_property =
  {
    key = "";
    value = None;
  }

(* TODO: make this a module to handle colors *)
(* This stackoverflow link is an example for constrained color values:
http://stackoverflow.com/questions/35107944/how-can-i-constrain-an-ocaml-integer-type-to-a-range-of-integers) *)

(* module Color : sig *)
(*   type t = *)
(*   | Basic of basic_color * weight   (\* basic colors, regular and bold *\) *)
(*   | RGB of rgbint * rgbint * rgbint (\* 6x6x6 color cube *\) *)
(*   | Gray of int                     (\* 24 grayscale levels *\) *)
(*   and basic_color = *)
(*    | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White *)
(*   and weight = Regular | Bold *)
(*   and rgbint = private int *)
(*   val rgb : int * int * int -> t *)
(* end = struct *)
(*   type t = *)
(*   | Basic of basic_color * weight *)
(*   | RGB   of rgbint * rgbint * rgbint *)
(*   | Gray  of int *)
(*   and basic_color = *)
(*    | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White *)
(*   and weight = Regular | Bold *)
(*   and rgbint = int *)

(*   let rgb (r, g, b) = *)
(*     let validate x = *)
(*       if x >= 0 && x < 6 then x else invalid_arg "Color.rgb" *)
(*     in *)
(*     RGB (validate r, validate g, validate b) *)
(*   end *)
(* With this definition, we can, of course, create Color.RGB values with the Color.rgb function: *)

(* # Color.rgb(0,0,0);; *)
(* - : Color.t = Color.RGB (0, 0, 0) *)
(* It is not possible to self-assemble a Color.RGB value out of its components: *)

(* # Color.RGB(0,0,0);; *)
(* Characters 10-11: *)
  (* Color.RGB(0,0,0);; *)
            (* ^ *)
(* Error: This expression has type int but an expression was expected of type *)
(*          Color.rgbint *)
(* It is possible to deconstruct values of type Color.rgbint as integers, using a type coercion: *)

(* # match Color.rgb(0,0,0) with *)
(*   | Color.RGB(r,g,b) -> *)
(*     if ((r,g,b) :> int * int * int) = (0, 0, 0) then *)
(*       "Black" *)
(*     else *)
(*       "Other" *)
(*   | _ -> "Other";;       *)
(* - : string = "Black" *)

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
let empty_style =
  {
    text_alignment = None;
    fill_color = None;
    line_color = None;
    font_color = None;
    line_width = None;
    font = None;
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
let empty_child =
  {
    id = "";
    child_type = "";
    model = None;
    name = None;
    target_connections = None;
    archimate_element = None;
    bounds = empty_bounds;
    children = [];
    source_connections = [];
    documentation = [];
    properties = [];
    style = None;
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
  label : string option;
  documentation : documentation list;
  properties : property list;
}

let empty_element =
  {
    id = "";
    element_type = None;
    label = None;
    documentation = [];
    properties = [];
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

let empty_folder =
  {
    id = "";
    name = "";
    folder_type = None;
    items = [];
    documentation = [];
    properties = [];
    folders = [];
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

let empty_model =
  {
    id = "";
    version = None;
    name = "";
    documentation = [];
    properties = [];
    elements = [];
    folders = [];
    relationships = [];
    diagrams = [];
  }

type tree =
    Data of string |
    Model of model |
    Documentation of documentation |
    Folder of folder |
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

let find_data_item a =
  match a with
  | Data _ -> true
  | _ -> false

let data_child_content childs =
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

let is_source_connection a =
  match a with
  | Source_connection _ -> true
  | _ -> false

let to_source_connection bv =
  match bv with
  | Source_connection b -> b
  | _ -> invalid_arg "Expected only source_connection values"

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

let is_folder a =
  match a with
  | Folder _ -> true
  | _ -> false

let to_folder a =
  match a with
  | Folder b -> b
  | _ -> invalid_arg "Expected only folder values"

let is_element a =
  match a with
  | Element _ -> true
  | _ -> false

let to_element a =
  match a with
  | Element b -> b
  | _ -> invalid_arg "Expected only element values"

let is_style a =
  match a with
  | Style _ -> true
  | _ -> false

let to_style a =
  match a with
  | Style b -> b
  | _ -> invalid_arg "Expected only style values"

let is_bendpoint a =
  match a with
  | Bendpoint _ -> true
  | _ -> false

let to_bendpoint bv =
  match bv with
  | Bendpoint b -> b
  | _ -> invalid_arg "Expected only bendpoint values"

let is_diagram a =
  match a with
  | Diagram _ -> true
  | _ -> false

let to_diagram n =
  match n with
  | Diagram d -> d
  | _ -> invalid_arg "Expected only diagram values"

let is_bounds a =
  match a with
  | Bounds _ -> true
  | _ -> false

let to_bounds bv =
  match bv with
  | Bounds b -> b
  | _ -> invalid_arg "Expected only bounds values"

let is_documentation a =
  match a with
  | Documentation _ -> true
  | _ -> false

let to_documentation a =
  match a with
  |  Documentation d -> d
  | _ -> invalid_arg "Expected only documentation values"

let is_child a =
  match a with
  | Child _ -> true
  | _ -> false

let to_child a =
  match a with
  | Child c -> c
  | _ -> invalid_arg "Expected only child values"

let find_all_nodes is_kind to_kind childs =
  List.filter is_kind childs |> List.map to_kind

let find_node is_kind to_kind childs =
  List.find is_kind childs |> to_kind
  (* with Not_found -> *)
  (*   Format.fprintf Format.std_formatter "Unable to find node"; *)
  (*   raise Not_found *)

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
  | Folder f -> f.id
  | Child c -> c.id
  | Source_connection s -> s.id
  | _ -> invalid_arg "Expected arg to have an id"

let folder_items childs =
  List.filter is_folder_item childs |>
  List.map id_for_tree_node

