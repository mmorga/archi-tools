open Printf

(*
BADGES = {
  "ApplicationInterface" => "#interface-badge",
  "ApplicationInteraction" => "#interaction-badge",
  "ApplicationCollaboration" => "#collaboration-badge",
  "ApplicationFunction" => "#function-badge",
  "BusinessActor" => "#actor-badge"
}
*)

(*
def draw_element_rect(xml, element, ctx)
  x = ctx["x"].to_i + ctx["width"].to_i - 25
  y = ctx["y"].to_i + 5
  el_type = element_type(element)
  case el_type
  when "ApplicationService", "BusinessService", "InfrastructureService"
    xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"], rx: "27.5", ry: "27.5")
  when "ApplicationInterface", "BusinessInterface"
    xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
    xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#interface-badge")
  when "BusinessActor"
    xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
    xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#actor-badge")
  when "ApplicationInteraction"
    xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"], rx: "10", ry: "10")
    xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#interaction-badge")
  when "ApplicationCollaboration", "BusinessCollaboration"
    xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
    xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#collaboration-badge")
  when "ApplicationFunction", "BusinessFunction", "InfrastructureFunction"
    xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"], rx: "10", ry: "10")
    xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#function-badge")
  when "ApplicationComponent"
    xml.rect(x: ctx["x"].to_i + 10, y: ctx["y"], width: ctx["width"].to_i - 10, height: ctx["height"])
    xml.use(x: "0", y: "0", width: "23", height: "44", class: "topbox", transform: "translate(#{ctx["x"]}, #{ctx["y"]})", "xlink:href" => "#component-knobs")
  when "DataObject"
    xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
    xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: "14", class: "topbox")
  else
    (* # puts "TODO: implement #{el_type}" *)
    $todos[el_type] += 1
    xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
  end
end *)

(* def element_text_bounds(element, ctx)
  case element_type(element)
  when "ApplicationService"
    {
      x: ctx["x"].to_i + 10, y: ctx["y"].to_i, width: ctx["width"].to_i - 20, height: ctx["height"]
    }
  when "DataObject"
    {
      x: ctx["x"].to_i + 5, y: ctx["y"].to_i + 14, width: ctx["width"].to_i - 10, height: ctx["height"]
    }
  else
    {
      x: ctx["x"].to_i + 5, y: ctx["y"].to_i, width: ctx["width"].to_i - 30, height: ctx["height"]
    }
  end
end
*)

let rec draw_element obj document ?context () =
  Xml.Element ("rect", [("x", "0"); ("y", "0"); ("width", "100"); ("height", "50")], []);;

  (* let (tag, attrs, children) = obj in *)
  (* let bounds = List.find (fun p -> Xml.tag p = "bounds") in *)
  (* let element_id = XmlUtil.attrib_val obj ["archimateElement"; "id"] in *)
  (* let element = XmlUtil.by_id document element_id in *)
  (* group_attrs = {id: element_id, class: element_type(element)} *)
  (* group_attrs[:transform] = "translate(#{context["x"]}, #{context["y"]})" unless context.nil? *)
  (* xml.g(group_attrs) { *)
    (* draw_element_rect(xml, element, bounds) *)
    (* tctx = element_text_bounds(element, bounds) *)
    (* y = tctx[:y].to_i *)
    (* x = bounds[:x].to_i + (bounds[:width].to_i / 2) *)
    (* content = element.attr("name") || element.at_css("content").text *)
    (* fit_text_to_width(content, tctx[:width].to_i).each { |line| *)
      (* y += 17 *)
      (* xml.text_(x: x, y: y, "text-anchor" => :middle) { *)
        (* xml.text line *)
      (* } *)
    (* } *)
    (* obj.css(">child").each { |child| draw_element(xml, child, bounds)} *)
  (* } *)
(* end *)

(* Construct a parser that doesn't check DTDs and parse the template SVG file *)
let svg_template svg_file =
  let p = XmlParser.make () in
  XmlParser.prove p false; (* Prevent errors trying to parse the DVD of SVG files *)
  XmlParser.parse p (XmlParser.SFile svg_file);;

let draw_children child =
  (* Make a simple rect SVG element as an XML Element *)
  (* Xml.Element ("rect", [("x", "0"); ("y", "0"); ("width", "100"); ("height", "50")], []);; *)
  draw_element child;;
  (* builder = Nokogiri::XML::Builder.with(svg) do |xml|
    draw_element(xml, child)
  end *)
  (* ();; *)

let make_svg archi_doc svg_template_file archi_diagram =
  let svg_doc = svg_template svg_template_file in
  let (_, attrs, children) = match archi_diagram with
      Xml.Element el -> el
    | Xml.PCData pc -> (pc, [], []) in
  let diagram_name = Xml.attrib archi_diagram "name" in

  (* Extract the Xml.Element tuple from the parsed SVG document - TODO: gotta be a better way *)
  let (s_tag, s_attrs, s_children) =
    match svg_doc with
      Xml.Element el -> el
    | Xml.PCData pc -> ("bogus", [], []) in

  (* TODO: need to annotate draw_children with the other params needed: svg_doc, others? *)
  (* TODO: make this a map call to collect the SVG elements to add to the diagram below *)
  (* List.iter draw_children children; *)
  let els = List.map draw_children children in
  ();;
  (* TODO: write to a file *)
  (* Insert the SVG rect element as a child of the root element producing a new SVG document *)
  (* let done_svg = Xml.Element(s_tag, s_attrs, s_children @ els) in
  printf "%s" (Xml.to_string_fmt done_svg);; *)

  (* File.open("generated/#{name}.svg", "wb") do |f|
    f.write(svg_doc.to_xml)
  end *)

let make_svgs archi_file svg_template_file =
  () ;;
  (* let archi_doc = Xml.parse_file archi_file in *)
  (* let make_diagram archi_diagram = make_svg archi_doc svg_template_file in *)
  (* List.iter (make_svg archi_doc svg_template_file) (Archimate.find_diagrams [] archi_doc);; *)
