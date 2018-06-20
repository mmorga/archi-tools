module Color :
  sig
    type color = { r : int; g : int; b : int; a : int option; }

    exception ValueError of string

    val black : color
    val create : int -> int -> int -> int option -> color
    val rgba : string option -> color option
    val printer : out_channel -> color option -> unit
  end