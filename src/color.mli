(** Color module contains functions for the Archimate Color type
 *)

type color = { r : int; g : int; b : int; a : int option; }
(** Type for color values. Per the Archimate interchange format
    spec, [r], [g], and [b] values are 0-255 and optional [a] is
    0-100.
 *)

exception ValueError of string
(** Exception raised in [create] when a value for r, g, b, or a
    is outside of accepted bounds.
 *)

val black : color
(** Returns a color for black
 *)

val create : int -> int -> int -> int option -> color
(** Create a color for the given values of red, green, blue,
    and optional alpha. [create 0xff 0 0xff (Some 50)] results
    in a half transparent purple color.
 *)

val rgba : string option -> color option
(** Parses a CSS style color string and returns an optional color
    for the string. [None] is returned if the color string is not
    valid.
 *)

val printer : out_channel -> color -> unit
(** Pretty printer for color values.
 *)

val to_rgba_string : color -> string
(** Produces a CSS style string for the color.
 *)
