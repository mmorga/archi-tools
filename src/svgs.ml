open Format
open Datamodel
open Tyxml
open Tyxml.Svg

let f_or_zero f =
  match f with
  | Some v -> v
  | None -> 0.0

let render_element m (c : child) =
  let el = match c.archimate_element with
    | Some id ->
      Some (List.find (fun (el : element) -> el.id = id) m.elements)
    | None -> None
  in
  let e_type = match el with
    | Some el -> el.el_type
    | None -> c.c_type
  in
  Svg.rect ~a:[
    a_x ((f_or_zero c.bounds.x), None);
    a_y ((f_or_zero c.bounds.y), None);
    a_width (c.bounds.width, None);
    a_height (c.bounds.height, None);
    a_style "stroke: black;fill: none;";
  ] []

let render_relationships d =
  []

let update_viewbox els rels =
    let width = 2000.0 in
    let height = 2000.0 in
    let min_x = 0.0 in
    let min_y = 0.0 in
    (min_x, min_y, width, height)

let diagram_to_svg m (d : Datamodel.diagram) : Tyxml.Svg.doc =
  let els = List.map (render_element m) d.children in
  let rels = render_relationships d in
  let viewbox = update_viewbox els rels in
  let (_, _, width, height) = viewbox in
  let svg_attrs id els rels =
    [
      (* TODO: calculate max extents and set attrs *)
      a_version "1.1";
      a_id id;
      a_width (width, None);
      a_height (height, None);
      a_viewBox viewbox
    ]
  in
  svg ~a:(svg_attrs d.id els rels) (List.concat [els; rels])

let export outdir m (d : Datamodel.diagram) =
  let filename = sprintf "%s/%s.svg" outdir d.id in
  let svg_file = open_out filename in
  let fmt = Format.formatter_of_out_channel svg_file in
  Svg.pp () fmt (diagram_to_svg m d);
  close_out svg_file

let svgs outdir m =
  List.iter (export outdir m) m.diagrams

