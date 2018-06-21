type color = {
  r : int;
  g : int;
  b : int;
  a : int option;
}

exception ValueError of string

let black = { r = 0; g = 0; b = 0; a = None; }

let max = 0xff

let create r g b a =
  if List.exists (fun i -> i < 0 || i > 255) [r; g; b] ||
     match a with None -> false | Some i -> i < 0 || i > 100
  then
    raise(ValueError "Color attribute outside of range")
  else
    { r = r; g = g; b = b; a = a }

let create_without_alpha r g b =
  Some { r = r; g = g; b = b; a = None }

let create_with_alpha r g b a = Some (create r g b (Some a))

let rgba_2_digit_with_alpha s = Scanf.sscanf s "#%2x%2x%2x%2x" create_with_alpha

let rgba_2_digit s = Scanf.sscanf s "#%2x%2x%2x" create_without_alpha

let rgba_1_digit_with_alpha s =
  let ss =
    Scanf.sscanf s "#%1s%1s%1s%1s" (fun r g b a -> Printf.sprintf "#%s%s%s%s%s%s%s%s" r r g g b b a a)
  in
  Scanf.sscanf ss "#%2x%2x%2x%2x" create_with_alpha

let rgba_1_digit s =
  let ss =
    Scanf.sscanf s "#%1s%1s%1s" (fun r g b  -> Printf.sprintf "#%s%s%s%s%s%s" r r g g b b)
  in
  Scanf.sscanf ss "#%2x%2x%2x" create_without_alpha

let rgba = function
  | None -> None
  | Some s -> (
    let funcs = [
        rgba_2_digit_with_alpha;
        rgba_2_digit;
        rgba_1_digit_with_alpha;
        rgba_1_digit
      ]
    in
    let func_wrapper s f =
      try
        f s
      with (Scanf.Scan_failure _)
          | (Failure _)
          | End_of_file -> None
    in
    let scans = List.map (func_wrapper s) funcs in
    let scanner_matched = function None -> false | _ -> true in
    try
      List.find scanner_matched scans
    with Not_found ->
      None
  )

let printer oc c =
  match c.a with
  | None -> Printf.fprintf oc "Color(#%02x%02x%02x)" c.r c.g c.b
  | Some a -> Printf.fprintf oc "Color(#%02x%02x%02x%02x)" c.r c.g c.b a

let to_rgba_string c =
  let scaled_alpha a =
    int_of_float ((float_of_int max) *. ((float_of_int a) /. 100.0) +. 0.5)
  in
  match c.a with
  | None -> Printf.sprintf "#%02x%02x%02x" c.r c.g c.b
  | Some a -> Printf.sprintf "#%02x%02x%02x%02x" c.r c.g c.b (scaled_alpha a)
