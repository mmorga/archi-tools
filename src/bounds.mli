(* TODO: make Comparable *)

type bounds = { x : float option; y : float option; width : float; height : float }

val zero : bounds

val bounds_of_location : float * float

val create : ?x:float -> ?y:float -> width:float -> height:float -> bounds

val printer : out_channel -> bounds -> unit
(** Pretty printer for bounds values.
 *)

val x_range : bounds -> float * float

val y_range : bounds -> float * float

val top : bounds -> float

val bottom : bounds -> float

val right : bounds -> float

val left : bounds -> float

val center : bounds -> bounds

val is_above : bounds -> bounds -> bool

val is_below : bounds -> bounds -> bool

val is_right_of : bounds -> bounds -> bool

val is_left_of : bounds -> bounds -> bool

val reduced_by : bounds -> bounds -> bounds

val is_inside : bounds -> bounds -> bool

val is_empty : bounds -> bool
