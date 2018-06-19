open Scanf

module Color =
  struct
    type color = {
      r : int; (*lt: 256 : gt: -1*)
      g : int; (*lt: 256 : gt: -1*)
      b : int; (*lt: 256 : gt: -1*)
      a : int option; (*lt: 101 : gt: -1*)
    }

    let black = { r = 0; g = 0; b = 0; a = None; }

    let rgba = function
      | None -> None
      | Some s ->
        let
          four_digit_scanner sr sg sb sa = Some { r = sr; g = sg; b = sb; a = Some sa; }
        in
        try
          Scanf.sscanf s "%2x%2x%2x%2x" four_digit_scanner
        with ex ->
          None

  end
