type bounds = { x : float option; y : float option; width : float; height : float }

let zero = { x = Some 0.; y = Some 0.; width = 0.; height = 0. }

let bounds_of_location location =
  let (x, y) = location in
  { x = Some x; y = Some y; width = 0.; height = 0. }

let create ?x ?y ~width ~height =
  { x = x; y = y; width = width; height = height }

let printer oc b =
  let x = match b.x with None -> "" | Some x -> Printf.sprintf "x: %f" x in
  let y = match b.y with None -> "" | Some y -> Printf.sprintf "y: %f" y in
  let width = Printf.sprintf "width: %f" b.width in
  let height = Printf.sprintf "height: %f" b.height in
  let args = String.concat ", " [x; y; width; height] in
  Printf.sprintf "Bounds(%s)" args

let left b = match b.x with None -> 0. | Some x -> x

let right b = (left b) +. b.width

let top b = match b.y with None -> 0. | Some y -> y

let bottom b = (top b) +. b.height

let x_range b = ((left b), (right b))

let y_range b = ((top b), (bottom b))

let center b = {
  x = Some ((left b) +. b.width /. 2.);
  y = Some ((top b) +. b.height /. 2.);
  width = 0.;
  height = 0.;
}

let is_above a b = (bottom a) < (top b)

let is_below a b = (top a) > (bottom b)

let is_right_of a b = (left a) > (right b)

let is_left_of a b = (right a) < (left b)

let reduced_by b v = {
  x = Some ((left b) +. v);
  y = Some ((top b) +.v);
  width = b.width -. (v *. 2.);
  height = b.height -. (v *. 2.);
}

let is_inside a b =
  (left a) > (left b) &&
  (right a) < (left b) &&
  (top a) > (top b) &&
  (bottom a) < (bottom b)

let is_empty a = (a.width == 0.) && (a.height == 0.)
