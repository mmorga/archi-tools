(** Returns true if element is an Archimate Diagram *)
let is_diagram el =
  let xsi_type = XmlUtil.attr_val el "xsi:type"
  and tag, _, _ = el in
  tag = "element" && xsi_type = "archimate:ArchimateDiagramModel";;

let rec find_diagrams diagram_list xdata =
  match xdata with
    Xml.PCData pc -> diagram_list
  | Xml.Element el ->
    Xml.fold find_diagrams (if is_diagram el then diagram_list @ [xdata] else diagram_list) xdata;
