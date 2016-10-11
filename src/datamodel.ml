open Core.Std

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

let validate color =
  let module V = Validate in
    let w check = V.field_folder color check in
      V.of_list
        (Fields.fold ~init:[]
          ~r:(w V.validate_bound 0 256)
          ~g:(w V.validate_bound 0 256)
          ~b:(w V.validate_bound 0 256)
          ~a:(w V.validate_bound 0 100)
        )

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
  model : string;
  name : string;
  target_connections : string;
  archimate_element : string;
  bounds : bounds;
  children : child list;
  source_connections : source_connection list;
  documentation : documentation list;
  properties : property list;
  style : style
}

type diagram = {
  id : string;
  name : string;
  viewpoint : string option;
  documentation : documentation list;
  properties : property list;
  children : child list;
  element_references : string list;
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

type folder = {
  id : string;
  name : string;
  folder_type : string option;
  items : string list;
  documentation : documentation list;
  properties : property list;
  folders : folder list;
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

type model = {
  id : string;
  name : string;
  documentation : documentation list;
  properties : property list;
  folders : folder list;
  relationships : relationship list;
  diagrams : diagram list;
}

