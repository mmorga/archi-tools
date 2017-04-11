open Format
open Datamodel
open Tyxml
open Tyxml.Svg

type node_content_type = (Svg_types.g_content Svg.elt) Svg.list_wrap

type diagram_node_type = {
  entity_shape : child -> element_name_type -> diagram_node_type -> bounds option -> (Svg_types.g_content Svg.elt) Svg.list_wrap;
  g_class : string;
  background_class : string;
  badge : string option;
}

let style_px_of_float f =
  let fr, iv = modf f in
  match fr with
  | 0. -> Format.sprintf "%dpx;" (int_of_float iv)
  | _ -> Format.sprintf "%0.2fpx;" f

(* def entity_shape(xml, bounds) application_component, artifact, data_entity, device, event_entity, group, interface_entity, junction, meaning, motivation_entity, node, note, process_entity, product, rect_entity, representation, rounded_rect_entity, service_entity, value *)
(* def initialize TechnologyCollaboration, SystemSoftware, Stakeholder, Sticky, ServiceEntity, RoundedRect, Resource, Requirement, Rect, Process, Principle, Plateau, Path, Outcome, OrJunction, Note, Node, Network, Motivation, Junction, Interface, Interaction, *)
(* def calc_text_bounds DataEntity, EventEntity, ProcessEntity, Value, see: set_text_bounds *)
(* def device_path(xml, bounds) Device *)
(* def elipse_path(xml, bounds) InterfaceEntity *)
(* def meaning_path(xml, bounds) Meaning *)
(* def node_path(xml, bounds) Node *)
(* def process_path(xml, bounds) ProcessEntity *)
(* def product_path(xml, bounds) Product *)
(* def representation_path(xml, bounds) - Representation *)
(* def service_path(xml, bounds) - ServiceEntity *)

let add_unless_none l kv =
  let k, v = kv in
  match v with
  | Some v ->
    (asprintf "%s:%s;" k v) :: l
  | None ->
    l

(* ******************************************** *)
(*      STYLE                                   *)
(* ******************************************** *)

let to_rgba c =
  let scaled_alpha a =
    let max = 255.0 in
    int_of_float (max *. ((float_of_int a) /. 100.0))
  in
  match c with
  | Some c -> (
      match c.a with
      | 100 -> Some (asprintf "#%02x%02x%02x" c.r c.g c.b)
      | _ -> Some (asprintf "#%02x%02x%02x%02x" c.r c.g c.b (scaled_alpha c.a))
    )
  | None -> None

let shape_style s =
  let maybe_string v =
    match v with
    | Some v -> Some (string_of_int v)
    | None -> None
  in
  match s with
  | Some style ->
    (
      let m = List.fold_left add_unless_none [] [
          ("fill", to_rgba style.fill_color);
          ("stroke", to_rgba style.line_color);
          ("stroke-width", maybe_string style.line_width)
        ]
      in
      String.concat "" m
    )
  | None -> ""

let text_style s =
  (* TODO: Add a default text_align *)
  let text_align s =
    match s.text_alignment with
    | Some ta -> Some (string_of_int ta)
    | None -> None
  in
  let font_size s =
    match s.font with
    | Some f -> Some (string_of_int f.size)
    | None -> None
  in
  let font_name s =
    match s.font with
    | Some f -> Some f.name
    | None -> None
  in
  match s with
  | Some style ->
    (
      let m = List.fold_left add_unless_none [] [
          ("fill", to_rgba style.font_color);
          ("color", to_rgba style.font_color);
          ("font-family", font_name style);
          ("font-size", font_size style);
          ("text-align", text_align style)
        ]
      in
      String.concat "" m
    )
  | None -> ""

(* produces SVG attributes list for a Datamodel.bounds *)
let bounds_attrs b =
  let f (a : Svg_types.coord -> [> `X ] Tyxml_svg.attrib) b l =
    match b with
    | Some fval -> (a (fval, None)) :: l
    | None -> l
  in
  let wh_list = [
      Svg.a_width (b.width, None);
      Svg.a_height (b.height, None)
    ]
  in
  f (Svg.a_x) b.x (f Svg.a_y b.y wh_list)

let entity_badge badge badge_bounds (l : node_content_type) : node_content_type =
  match badge with
  | Some b ->
    let badge_use = (Svg.use ~a:(List.append (bounds_attrs badge_bounds) [Svg.a_xlink_href ("#" ^ b)]) []) in
    badge_use :: l
  | None -> l

(* TODO use this in entity_label below *)
let element_trimmed_name (e : element option) : string option =
  match e with
  | Some el -> (
      match el.node.name with
      | Some name -> (
          let trimmed_name = String.trim name in
          match trimmed_name with
          | "" -> None
          | _ -> Some trimmed_name
        )
      | None -> None
    )
  | None -> None

let entity_label ?(align = "center") (c : child) (e : element_name_type) text_bounds badge l : node_content_type =
  let text_lines text =
    Str.global_replace (Str.regexp "\\r\\n") "\n" text |> Str.split (Str.regexp "[\r\n]")
  in
  let name =
    match e.name with
    | Some n -> n
    | None -> c.id
  in
  let optional_spacer bo l =
    match bo with
    | Some b -> (
        Html.div ~a:[Html.a_class ["archimate-badge-spacer"]] [];
      ) :: l
    | None -> l
  in
  let label_style = ((text_style c.node.style) ^ "text-align:" ^ align ^ ";") in
  (
    Svg.foreignObject ~a:(bounds_attrs text_bounds) [
      Html.toelt (
        Html.table ~a:[
          Html.a_xmlns `W3_org_1999_xhtml;
          Html.a_style (
            "height:" ^ (style_px_of_float text_bounds.height) ^ "width:" ^ (style_px_of_float text_bounds.width)
          );
        ] [
          Html.tr ~a:[Html.a_style ("height:" ^ (style_px_of_float text_bounds.height))] [
            Html.td ~a:[Html.a_class ["entity-name"]] (
              optional_spacer badge [
                Html.p ~a:[Html.a_class ["entity-name"]; Html.a_style label_style] (
                  List.map (fun line -> Html.pcdata line) (text_lines name) (* TODO: add Html5.br *)
                );
              ]
            )
          ]
        ]
      )
    ]
  ) :: l

let conditional_add f_cont f_cond x l =
  match (f_cond x) with
  | true -> List.append [f_cont x] l
  | false -> l

let f_or_zero (f : float option) : float =
  match f with
  | Some v -> v
  | None -> 0.0

let translate_bounds (b : bounds) =
    Svg.a_transform [`Translate ((f_or_zero b.x), b.y)]

let rect_badge_bounds b =
  {
    x = Some ((bounds_right b) -. 25.);
    y = Some ((bounds_top b) +. 5.);
    width = 20.;
    height = 20.;
  }

let rect_shape (c : child) (e : element_name_type) (dnt : diagram_node_type) (bounds_offset : bounds option) =
  let text_bounds = bounds_reduce_by c.node.bounds 2.0 in
  List.rev (
    entity_label c e text_bounds dnt.badge (
      entity_badge dnt.badge (rect_badge_bounds c.node.bounds) [
        Svg.rect ~a:[
          Svg.a_x ((bounds_left c.node.bounds), None);
          Svg.a_y ((bounds_top c.node.bounds), None);
          Svg.a_width (c.node.bounds.width, None);
          Svg.a_height (c.node.bounds.height, None);
          Svg.a_class [dnt.background_class];
          Svg.a_style (shape_style c.node.style);
        ] [];
      ]
    )
  )

let rect_helper x y w h cls sty =
  Svg.rect ~a:[
    Svg.a_x (x, None);
    Svg.a_y (y, None);
    Svg.a_width (w, None);
    Svg.a_height (h, None);
    Svg.a_class [cls];
    Svg.a_style sty;
  ] []

let group_shape (c : child) (e : element_name_type) (dnt : diagram_node_type) (bounds_offset : bounds option) =
  let group_header_height = 21. in
  let bounds = c.node.bounds in
  let text_bounds = { bounds with height = group_header_height; } in
  List.rev (
    entity_label ~align:"left" c e text_bounds dnt.badge [
      Svg.rect ~a:[
        Svg.a_x ((bounds_left bounds), None);
        Svg.a_y ((bounds_top bounds), None);
        Svg.a_width ((bounds.width /. 2.), None);
        Svg.a_height ((group_header_height), None);
        Svg.a_class ["archimate-decoration"];
      ] [];
      Svg.rect ~a:[
        Svg.a_x (bounds_left bounds, None);
        Svg.a_y ((bounds_top bounds), None);
        Svg.a_width (bounds.width /. 2., None);
        Svg.a_height (group_header_height, None);
        Svg.a_class [dnt.background_class];
        Svg.a_style (shape_style c.node.style);
      ] [];
      Svg.rect ~a:[
        Svg.a_x (bounds_left bounds, None);
        Svg.a_y ((bounds_top bounds) +. group_header_height, None);
        Svg.a_width (bounds.width, None);
        Svg.a_height (bounds.height -. group_header_height, None);
        Svg.a_class [dnt.background_class];
        Svg.a_style (shape_style c.node.style);
      ] [];
    ]
  )

let junction_shape c e dnt bounds_offset =
  rect_shape c e dnt bounds_offset

let component_shape c e dnt bounds_offset =
  let s_style = shape_style c.node.style in
  let component_decoration left top =
    [
      Svg.rect ~a:[
        Svg.a_x (left, None);
        Svg.a_y (top, None);
        Svg.a_width (21.0, None);
        Svg.a_height (13.0, None);
        Svg.a_class ["archimate-decoration"]
      ] [];
      Svg.rect ~a:[
        Svg.a_x (left, None);
        Svg.a_y (top, None);
        Svg.a_width (21.0, None);
        Svg.a_height (13.0, None);
        Svg.a_class [dnt.background_class];
        Svg.a_style s_style
      ] [];
    ]
  in
  let main_box_x = bounds_left c.node.bounds +. 21.0 /. 2.0 in
  let main_box_width = c.node.bounds.width -. 21.0 /. 2.0 in
  let text_bounds = {
      x = Some (main_box_x +. 21.0 /. 2.0);
      y = Some ((bounds_top c.node.bounds) +. 1.0);
      width = c.node.bounds.width -. 22.0;
      height = c.node.bounds.height -. 2.0
    }
  in
  List.rev (
    entity_label c e text_bounds dnt.badge (
      entity_badge dnt.badge (rect_badge_bounds c.node.bounds) (
        List.concat [
          component_decoration (bounds_left c.node.bounds) ((bounds_top c.node.bounds) +. 10.0);
          component_decoration (bounds_left c.node.bounds) ((bounds_top c.node.bounds) +. 30.0);
          [
            Svg.rect ~a:[
              Svg.a_x (main_box_x, None);
              Svg.a_y (bounds_top c.node.bounds, None);
              Svg.a_width (main_box_width, None);
              Svg.a_height (c.node.bounds.height, None);
              Svg.a_class [dnt.background_class];
              Svg.a_style s_style
            ] []
          ];
        ]
      )
    )
  )

let child_diagram_node_type c e =
  let layer_background_class l =
    match l with
    | StrategyLayer -> "archimate-strategy-background"
    | BusinessLayer -> "archimate-business-background"
    | ApplicationLayer -> "archimate-application-background"
    | TechnologyLayer -> "archimate-infrastructure-background"
    | PhysicalLayer -> "archimate-physical-background"
    | MotivationLayer -> "archimate-motivation-background"
    | ImplementationAndMigrationLayer -> "archimate-implementation-background"
    | Junction -> ""
  in
  let default_bg_class =
    match e.entity with
    | ElementRef el -> layer_background_class el.node.layer
    | GroupRef -> "archimate-group-background"
    | NoteRef -> "archimate-note-background"
    | DiagramModelRef _ -> "archimate-diagram-model-background"
    | SketchModelStickyRef -> "archimate-sketch-model-sticky-background"
  in
  let default_diagram_node_type = {
      entity_shape = rect_shape;
      g_class = "archimate-shape";
      background_class = default_bg_class;
      badge = None;
    }
  in
  match e.el_type with
  | AndJunction -> { default_diagram_node_type with g_class = "archimate-and-junction"; background_class = "archimate-junction-background"; }
  | Junction -> { default_diagram_node_type with g_class = "archimate-junction"; entity_shape = junction_shape; background_class = "archimate-junction-background"; }
  | OrJunction -> { default_diagram_node_type with g_class = "archimate-or-junction"; entity_shape = rect_shape; background_class = "archimate-or-junction-background"; }
  | BusinessActor -> { default_diagram_node_type with g_class = "archimate-business-actor"; badge = Some "archimate-actor-badge"; }
  | BusinessCollaboration -> { default_diagram_node_type with g_class = "archimate-business-collaboration"; badge = Some "archimate-collaboration-badge"; }
  | BusinessEvent -> { default_diagram_node_type with g_class = "archimate-business-event"; }
  | BusinessFunction  -> { default_diagram_node_type with g_class = "archimate-business-function"; badge = Some "archimate-function-badge"; }
  | BusinessInteraction -> { default_diagram_node_type with g_class = "archimate-business-interaction"; badge = Some "archimate-interaction-badge"; }
  | BusinessInterface -> { default_diagram_node_type with g_class = "archimate-business-interface"; badge = Some "archimate-interface-badge"; }
  | BusinessObject -> { default_diagram_node_type with g_class = "archimate-business-object"; }
  | BusinessProcess -> { default_diagram_node_type with g_class = "archimate-business-process"; badge = Some "archimate-process-badge"; }
  | BusinessRole -> { default_diagram_node_type with g_class = "archimate-business-role"; badge = Some "archimate-role-badge"; }
  | BusinessService -> { default_diagram_node_type with g_class = "archimate-business-service"; badge = Some "archimate-service-badge"; }
  | Contract -> { default_diagram_node_type with g_class = "archimate-contract"; }
  | Meaning -> { default_diagram_node_type with g_class = "archimate-meaning"; }
  | Product -> { default_diagram_node_type with g_class = "archimate-product"; }
  | Representation -> { default_diagram_node_type with g_class = "archimate-representation"; }
  | Value -> { default_diagram_node_type with g_class = "archimate-value"; }
  | ApplicationCollaboration -> { default_diagram_node_type with g_class = "archimate-application-collaboration"; badge = Some "archimate-collaboration-badge"; }
  | ApplicationComponent -> { default_diagram_node_type with g_class = "archimate-application-component"; entity_shape = component_shape; }
  | ApplicationFunction -> { default_diagram_node_type with g_class = "archimate-application-function"; badge = Some "archimate-function-badge"; }
  | ApplicationInteraction -> { default_diagram_node_type with g_class = "archimate-application-interaction"; badge = Some "archimate-interaction-badge"; }
  | ApplicationInterface -> { default_diagram_node_type with g_class = "archimate-application-interface"; badge = Some "archimate-interface-badge"; }
  | ApplicationService -> { default_diagram_node_type with g_class = "archimate-application-service"; badge = Some "archimate-service-badge"; }
  | DataObject -> { default_diagram_node_type with g_class = "archimate-data-object"; }
  | Artifact -> { default_diagram_node_type with g_class = "archimate-artifact"; }
  | CommunicationPath -> { default_diagram_node_type with g_class = "archimate-communication-path"; badge = Some "archimate-communication-badge"; }
  | Device -> { default_diagram_node_type with g_class = "archimate-device"; badge = Some "archimate-device-badge"; }
  | InfrastructureFunction -> { default_diagram_node_type with g_class = "archimate-infrastructure-function"; badge = Some "archimate-function-badge"; }
  | InfrastructureInterface -> { default_diagram_node_type with g_class = "archimate-infrastructure-interface"; badge = Some "archimate-interface-badge"; }
  | InfrastructureService -> { default_diagram_node_type with g_class = "archimate-infrastructure-service"; badge = Some "archimate-service-badge"; }
  | Network -> { default_diagram_node_type with g_class = "archimate-network"; badge = Some "archimate-network-badge"; }
  | Node -> { default_diagram_node_type with g_class = "archimate-node"; badge = Some "archimate-node-badge"; }
  | SystemSoftware -> { default_diagram_node_type with g_class = "archimate-system-software"; badge = Some "archimate-system-software-badge"; }
  | Assessment -> { default_diagram_node_type with g_class = "archimate-assessment"; badge = Some "archimate-assessment-badge"; }
  | Constraint -> { default_diagram_node_type with g_class = "archimate-constraint"; badge = Some "archimate-constraint-badge"; }
  | Driver -> { default_diagram_node_type with g_class = "archimate-driver"; badge = Some "archimate-driver-badge"; }
  | Goal -> { default_diagram_node_type with g_class = "archimate-goal"; badge = Some "archimate-goal-badge"; }
  | Principle -> { default_diagram_node_type with g_class = "archimate-principle"; badge = Some "archimate-principle-badge"; }
  | Requirement -> { default_diagram_node_type with g_class = "archimate-requirement"; badge = Some "archimate-requirement-badge"; }
  | Stakeholder -> { default_diagram_node_type with g_class = "archimate-stakeholder"; }
  | Deliverable -> { default_diagram_node_type with g_class = "archimate-deliverable"; }
  | Gap -> { default_diagram_node_type with g_class = "archimate-gap"; badge = Some "archimate-gap-badge"; }
  | Location -> { default_diagram_node_type with g_class = "archimate-location"; badge = Some "archimate-location-badge"; }
  | Plateau -> { default_diagram_node_type with g_class = "archimate-plateau"; badge = Some "archimate-plateau-badge"; }
  | WorkPackage -> { default_diagram_node_type with g_class = "archimate-work-package"; }
  | DiagramModelReference -> { default_diagram_node_type with g_class = "archimate-diagram-model-reference"; badge = Some "archimate-diagram-model-reference-badge"; }
  | Group -> { default_diagram_node_type with g_class = "archimate-group"; entity_shape = group_shape; }
  | DiagramObject -> { default_diagram_node_type with g_class = "archimate-diagram-object"; }
  | Note -> { default_diagram_node_type with g_class = "archimate-note"; }
  | SketchModelSticky -> { default_diagram_node_type with g_class = "archimate-sketch-model-sticky"; }

(* TODO: Transform only needed only for Archi file types *)
let group_attrs e g_class bounds_offset =
  let add_bounds bo l =
    match bo with
    | Some b -> (translate_bounds b) :: l
    | None -> l
  in
  add_bounds bounds_offset [
    Svg.a_id e.id;
    Svg.a_class [g_class];
  ]

let rec to_svg m bounds_offset (c : child) =
  let e = effective_child_element c m in
  let dnt = child_diagram_node_type c e in
  let add_title e l =
    match e.name with
    | Some name -> (Svg.title (Svg.pcdata name) :: l)
    | None -> l
  in
  let add_desc c l =
    match (List.length c.documentation) with
    | 0 -> l
    | _ ->
      (Svg.desc (Svg.pcdata (String.concat "\n\n" (List.map (fun doc -> doc.content) c.documentation)))) :: l
  in
  let title_dest c e =
    add_title e (
      add_desc c []
    )
  in
  Svg.g ~a:(group_attrs e dnt.g_class bounds_offset) (
    List.concat [
      title_dest c e;
      dnt.entity_shape c e dnt bounds_offset;
      List.map (to_svg m (Some c.node.bounds)) c.node.children
    ]
  )

let render_relationships d =
  []

let update_viewbox els rels =
    let width = 2000.0 in
    let height = 2000.0 in
    let min_x = 0.0 in
    let min_y = 0.0 in
    (min_x, min_y, width, height)

let diagram_to_svg (m : Datamodel.model) (d : Datamodel.diagram) : string =
  let els = List.map (to_svg m None) d.node.children in
  let rels = render_relationships d in
  let viewbox = update_viewbox els rels in
  let (min_x, min_y, width, height) = viewbox in
  let template = Mustache.of_string Svg_template.svg in
  let contents = List.map (Format.asprintf "%a\n" (Svg.pp_elt ())) (List.concat [els; rels])
  in
  let json = `O [
      "stylesheet", `String Svg_template.css;
      "min_x", `Float min_x;
      "min_y", `Float min_y;
      "width", `Float width;
      "height", `Float height;
      "content", `String (String.concat "\n" contents)
    ]
  in
  Mustache.render template json

let export outdir (m : Datamodel.model) (d : Datamodel.diagram) =
  let filename = sprintf "%s/%s.svg" outdir d.id in
  let svg_file = open_out filename in
  let fmt = Format.formatter_of_out_channel svg_file in
  (* Svg.pp () (diagram_to_svg m d); *)
  fprintf fmt "%s" (diagram_to_svg m d);
  close_out svg_file

let svgs outdir (m : model) =
  List.iter (export outdir m) m.node.diagrams

