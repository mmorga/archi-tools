type bendpoint = {
  start_x : float option;
  start_y : float option;
  end_x : float option;
  end_y : float option;
}
val empty_bendpoint : bendpoint
type bounds = {
  x : float option;
  y : float option;
  width : float;
  height : float;
}
val empty_bounds : bounds
type documentation = { lang : string option; content : string; }
val empty_documentation : documentation
type property = { key : string; value : string option; }
val empty_property : property
type color = { r : int; g : int; b : int; a : int; }
type font = { name : string; size : int; style : string option; }
type style = {
  text_alignment : int option;
  fill_color : color option;
  line_color : color option;
  font_color : color option;
  line_width : int option;
  font : font option;
}
val empty_style : style
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
val empty_child : child
type diagram = {
  id : string;
  name : string;
  viewpoint : string option;
  documentation : documentation list;
  properties : property list;
  children : child list;
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
val empty_element : element
type folder = {
  id : string;
  name : string;
  folder_type : string option;
  items : string list;
  documentation : documentation list;
  properties : property list;
  folders : folder list;
}
val empty_folder : folder
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
val empty_model : model
type tree =
    Data of string
  | Model of model
  | Documentation of documentation
  | Folder of folder
  | Element of element
  | Relationship of relationship
  | Diagram of diagram
  | Child of child
  | Bounds of bounds
  | Source_connection of source_connection
  | Style of style
  | Bendpoint of bendpoint
  | Property of property
  | Unknown of string
val find_data_item : tree -> bool
val data_child_content : tree list -> string
val is_source_connection : tree -> bool
val to_source_connection : tree -> source_connection
val is_property : tree -> bool
val to_property : tree -> property
val is_relationship : tree -> bool
val to_relationship : tree -> relationship
val is_folder : tree -> bool
val to_folder : tree -> folder
val is_element : tree -> bool
val to_element : tree -> element
val is_style : tree -> bool
val to_style : tree -> style
val is_bendpoint : tree -> bool
val to_bendpoint : tree -> bendpoint
val is_diagram : tree -> bool
val to_diagram : tree -> diagram
val is_bounds : tree -> bool
val to_bounds : tree -> bounds
val is_documentation : tree -> bool
val to_documentation : tree -> documentation
val is_child : tree -> bool
val to_child : tree -> child
val find_all_nodes : ('a -> bool) -> ('a -> 'b) -> 'a list -> 'b list
val find_node : ('a -> bool) -> ('a -> 'b) -> 'a list -> 'b
val find_optional_node : ('a -> bool) -> ('a -> 'b) -> 'a list -> 'b option
val is_folder_item : tree -> bool
val id_for_tree_node : tree -> string
val folder_items : tree list -> string list
