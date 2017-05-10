open Format

type archimate_layer =
  BusinessLayer |
  ApplicationLayer |
  TechnologyLayer |
  MotivationLayer |
  StrategyLayer |
  Junction |
  ImplementationAndMigrationLayer |
  PhysicalLayer

type bendpoint = {
  start_x : float option;
  start_y : float option;
  end_x : float option;
  end_y : float option;
}

type bounds = { x : float option; y : float option; width : float; height : float }

let bounds_left b =
  match b.x with
  | Some x -> x
  | None -> 0.0

let bounds_right b =
  (bounds_left b) +. b.width

let bounds_top b =
  match b.y with
  | Some y -> y
  | None -> 0.0

let bounds_bottom b =
  (bounds_top b) +. b.height

let bounds_reduce_by b f =
  let half_f = f /. 2.0 in
  {
    x = (
      match b.x with
      | Some x -> Some (x +. half_f)
      | None -> Some half_f
    );
    y = (
      match b.y with
      | Some y -> Some (y +. half_f)
      | None -> Some half_f
    );
    width = b.width -. f;
    height = b.height -. f;
  }

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

type 'a identified = {
  node : 'a;
  id : string;
  documentation : documentation list;
  properties : property list;
}

type source_connection_attrs = {
  source : string;
  target : string;
  relationship : string option;
  name : string option;
  source_connection_type : string option;
  bendpoints : bendpoint list;
  style : style option;
}

type source_connection = source_connection_attrs identified

type element_type =
  AndJunction |
  Junction |
  OrJunction |
  BusinessActor |
  BusinessCollaboration |
  BusinessEvent |
  BusinessFunction |
  BusinessInteraction |
  BusinessInterface |
  BusinessObject |
  BusinessProcess |
  BusinessRole |
  BusinessService |
  Contract |
  Meaning |
  Product |
  Representation |
  Value |
  ApplicationCollaboration |
  ApplicationComponent |
  ApplicationFunction |
  ApplicationInteraction |
  ApplicationInterface |
  ApplicationService |
  DataObject |
  Artifact |
  CommunicationPath |
  Device |
  InfrastructureFunction |
  InfrastructureInterface |
  InfrastructureService |
  Network |
  Node |
  SystemSoftware |
  Assessment |
  Constraint |
  Driver |
  Goal |
  Principle |
  Requirement |
  Stakeholder |
  Deliverable |
  Gap |
  Location |
  Plateau |
  WorkPackage |
  DiagramModelReference |
  Group |
  DiagramObject |
  Note |
  SketchModelSticky

let string_of_element_type = function
  | AndJunction -> "AndJunction"
  | Junction -> "Junction"
  | OrJunction -> "OrJunction"
  | BusinessActor -> "BusinessActor"
  | BusinessCollaboration -> "BusinessCollaboration"
  | BusinessEvent -> "BusinessEvent"
  | BusinessFunction -> "BusinessFunction"
  | BusinessInteraction -> "BusinessInteraction"
  | BusinessInterface -> "BusinessInterface"
  | BusinessObject -> "BusinessObject"
  | BusinessProcess -> "BusinessProcess"
  | BusinessRole -> "BusinessRole"
  | BusinessService -> "BusinessService"
  | Contract -> "Contract"
  | Meaning -> "Meaning"
  | Product -> "Product"
  | Representation -> "Representation"
  | Value -> "Value"
  | ApplicationCollaboration -> "ApplicationCollaboration"
  | ApplicationComponent -> "ApplicationComponent"
  | ApplicationFunction -> "ApplicationFunction"
  | ApplicationInteraction -> "ApplicationInteraction"
  | ApplicationInterface -> "ApplicationInterface"
  | ApplicationService -> "ApplicationService"
  | DataObject -> "DataObject"
  | Artifact -> "Artifact"
  | CommunicationPath -> "CommunicationPath"
  | Device -> "Device"
  | InfrastructureFunction -> "InfrastructureFunction"
  | InfrastructureInterface -> "InfrastructureInterface"
  | InfrastructureService -> "InfrastructureService"
  | Network -> "Network"
  | Node -> "Node"
  | SystemSoftware -> "SystemSoftware"
  | Assessment -> "Assessment"
  | Constraint -> "Constraint"
  | Driver -> "Driver"
  | Goal -> "Goal"
  | Principle -> "Principle"
  | Requirement -> "Requirement"
  | Stakeholder -> "Stakeholder"
  | Deliverable -> "Deliverable"
  | Gap -> "Gap"
  | Location -> "Location"
  | Plateau -> "Plateau"
  | WorkPackage -> "WorkPackage"
  | DiagramModelReference -> "DiagramModelReference"
  | Group -> "Group"
  | DiagramObject -> "DiagramObject"
  | Note -> "Note"
  | SketchModelSticky -> "SketchModelSticky"


type child_attrs = {
  el_type : element_type;
  name : string option;
  model : string option;
  target_connections : string option;
  archimate_element : string option;
  bounds : bounds;
  children : (child_attrs identified) list;
  source_connections : source_connection list;
  style : style option;
  alt_view : bool;
}

type child = child_attrs identified

let print_child c =
  let opt_rep = function
    | Some s -> s
    | None -> "None"
  in
  open_hvbox 2;
  print_string "Child (";
  open_hbox (); print_string ("id = \"" ^ c.id ^ "\", "); close_box ();
  open_hbox (); print_string ("el_type = " ^ (string_of_element_type c.node.el_type) ^ ", "); close_box ();
  open_hbox (); print_string ("name = " ^ (opt_rep c.node.name) ^ ", "); close_box ();
  open_hbox (); print_string ("model = " ^ (opt_rep c.node.model) ^ ", "); close_box ();
  open_hbox (); print_string ("target_connections = " ^ (opt_rep c.node.target_connections) ^ ", "); close_box ();
  open_hbox (); print_string ("archimate_element = " ^ (opt_rep c.node.archimate_element)); close_box ();
  print_string ")";
  close_box ();
  print_string "\n"

type diagram_type =
    Sketch |
    Diagram

type diagram_attrs = {
  name : string;
  viewpoint : string option;
  children : child list;
  (* element_references : string list; *)
  connection_router_type : int option;
  dia_type : diagram_type;
}

type diagram = diagram_attrs identified

type element_attrs = {
  el_type : element_type;
  name : string option;
  layer : archimate_layer;
}

type element = element_attrs identified

type relationship_type =
    Access |
    Aggregation |
    Assignment |
    Association |
    Composition |
    Flow |
    Influence |
    Realization |
    Specialization |
    Triggering |
    UsedBy

type relationship_attrs = {
  rel_type : relationship_type;
  source : string;
  target : string;
  name : string option;
}

type relationship = relationship_attrs identified

type folder_attrs = {
  name : string;
  folder_type : string option;
  items : string list;
  folders : (folder_attrs identified) list;
}

type folder = folder_attrs identified

type archimate_version = ArchiMate2_1 | ArchiMate3_0 | None

type model_attrs = {
  version : archimate_version;
  name : string;
  elements : element list;
  folders : folder list;
  relationships : relationship list;
  diagrams : diagram list;
}

type model = model_attrs identified

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

let element_by_id m id =
  List.find (fun (e : 'a identified) : bool -> e.id = id) m.node.elements

type element_name_attrs = {
  el_type : element_type;
  name : string option;
}

type child_ref =
    ElementRef of element |
    DiagramModelRef of diagram |
    GroupRef |
    NoteRef |
    SketchModelStickyRef

type element_name_type = {
  id : string;
  el_type : element_type;
  name : string option;
  entity : child_ref;
}

let effective_child_element (c : child) m =
  let expected_id = function
    | Some id -> id
    | None -> print_child c; invalid_arg "Expected an id attribute for Child type"
  in
  match c.node.el_type with
  | DiagramObject ->
    let archimate_element_id = expected_id c.node.archimate_element in
    let element = List.find (fun (e : element) -> archimate_element_id = e.id) m.node.elements in
    {
      id = archimate_element_id;
      el_type = element.node.el_type;
      name = element.node.name;
      entity = ElementRef element;
    }
  | DiagramModelReference ->
    let diagram_id = expected_id c.node.model in
    let diagram = List.find (fun (d : diagram) -> d.id = diagram_id) m.node.diagrams in
    {
      id = diagram_id;
      el_type = DiagramModelReference;
      name = Some diagram.node.name;
      entity = DiagramModelRef diagram;
    }
  | Group ->
    {
      id = c.id;
      el_type = Group;
      name = c.node.name;
      entity = GroupRef;
    }
  | Note ->
    {
      id = c.id;
      el_type = Note;
      name = c.node.name;
      entity = NoteRef;
    }
  | SketchModelSticky ->
    {
      id = c.id;
      el_type = SketchModelSticky;
      name = c.node.name;
      entity = SketchModelStickyRef;
    }
  | _ -> invalid_arg ("Unexpected element type `" ^ (string_of_element_type c.node.el_type) ^ "` for child")

let is_bendpoint = function
  | Bendpoint _ -> true
  | _ -> false

let to_bendpoint = function
  | Bendpoint b -> b
  | _ -> invalid_arg "Expected only bendpoint values"

let is_bounds = function
  | Bounds _ -> true
  | _ -> false

let to_bounds = function
  | Bounds b -> b
  | _ -> invalid_arg "Expected only bounds values"

let is_child = function
  | Child _ -> true
  | _ -> false

let to_child = function
  | Child c -> c
  | _ -> invalid_arg "Expected only child values"

let is_diagram = function
  | Diagram _ -> true
  | _ -> false

let to_diagram = function
  | Diagram d -> d
  | _ -> invalid_arg "Expected only diagram values"

let is_documentation = function
  | Documentation _ -> true
  | _ -> false

let to_documentation = function
  |  Documentation d -> d
  | _ -> invalid_arg "Expected only documentation values"

let is_element = function
  | Element _ -> true
  | _ -> false

let to_element = function
  | Element b -> b
  | _ -> invalid_arg "Expected only element values"

let is_folder = function
  | Folder _ -> true
  | _ -> false

let to_folder = function
  | Folder (b, c) -> b
  | _ -> invalid_arg "Expected only folder values"

let filter_folders childs =
  List.filter is_folder childs

let filter_folder_recs childs =
  filter_folders childs |> List.map to_folder

let is_property = function
  | Property _ -> true
  | _ -> false

let to_property = function
  | Property p -> p
  | _ -> invalid_arg "Expected only property values"

let is_relationship = function
  | Relationship _ -> true
  | _ -> false

let to_relationship = function
  | Relationship b -> b
  | _ -> invalid_arg "Expected only relationship values"

let is_source_connection = function
  | Source_connection _ -> true
  | _ -> false

let to_source_connection = function
  | Source_connection b -> b
  | _ -> invalid_arg "Expected only source_connection values"

let is_style = function
  | Style _ -> true
  | _ -> false

let to_style = function
  | Style b -> b
  | _ -> invalid_arg "Expected only style values"

(* Return the string content of Data nodes in a list of children *)
let data_child_content childs =
  let find_data_item = function
    | Data _ -> true
    | _ -> false
  in
  try
    let data_item = List.find find_data_item childs in
    match data_item with
    | Data s -> s
    | _ -> ""
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

let is_folder_item (a : tree) =
  match a with
  | Element _
  | Relationship _
  | Diagram _ -> true
  | _ -> false

let id_for_tree_node (a : tree) =
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

let rec find_all_in_folder is_kind to_kind = function
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

