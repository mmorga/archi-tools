
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

(* TODO: make this a module to handle colors *)
(* This stackoverflow link is an example for constrained color values:
http://stackoverflow.com/questions/35107944/how-can-i-constrain-an-ocaml-integer-type-to-a-range-of-integers) *)

module Color : sig
  type t =
  | Basic of basic_color * weight   (* basic colors, regular and bold *)
  | RGB of rgbint * rgbint * rgbint (* 6x6x6 color cube *)
  | Gray of int                     (* 24 grayscale levels *)
  and basic_color =
   | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
  and weight = Regular | Bold
  and rgbint = private int
  val rgb : int * int * int -> t
end = struct
  type t =
  | Basic of basic_color * weight
  | RGB   of rgbint * rgbint * rgbint
  | Gray  of int
  and basic_color =
   | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
  and weight = Regular | Bold
  and rgbint = int

  let rgb (r, g, b) =
    let validate x =
      if x >= 0 && x < 6 then x else invalid_arg "Color.rgb"
    in
    RGB (validate r, validate g, validate b)
  end
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

type archimate_version = ArchiMate2_1 | ArchiMate3_0

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
