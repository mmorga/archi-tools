open Format
open Datamodel
open Tyxml
open Tyxml.Svg
open Svg_helpers.Path

type node_content_type = (Svg_types.g_content elt) list_wrap

type diagram_node_type = {
  entity_shape : child -> element_name_type -> diagram_node_type -> (Svg_types.g_content elt) list_wrap;
  g_class : string;
  background_class : string;
  badge : string option;
}

let vs v =
  let fr, iv = modf v in
  match fr with
  | 0. -> asprintf "%d" (int_of_float iv)
  | _ -> asprintf "%f" v

let style_px_of_float f =
  asprintf "%spx;" (vs f)

(* def entity_shape(xml, bounds) artifact, data_entity, device, event_entity, group, interface_entity, junction, meaning, motivation_entity, node, note, process_entity, product, rect_entity, representation, rounded_rect_entity, service_entity, value *)
(* def initialize TechnologyCollaboration, SystemSoftware, Stakeholder, Sticky, ServiceEntity, RoundedRect, Resource, Requirement, Rect, Process, Principle, Plateau, Path, Outcome, OrJunction, Note, Node, Network, Motivation, Junction, Interface, Interaction, *)
(* def calc_text_bounds DataEntity, EventEntity, ProcessEntity, Value, see: set_text_bounds *)

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
  let maybe_string = function
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
  (* TODO: Add a default text_align? *)
  let text_align s =
    match s.text_alignment with
    | Some 1 -> Some "left"
    | Some 2 -> Some "center"
    | Some 3 -> Some "right"
    | _ -> None
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
      a_width (b.width, None);
      a_height (b.height, None)
    ]
  in
  f (a_x) b.x (f a_y b.y wh_list)

let entity_badge badge badge_bounds (l : node_content_type) : node_content_type =
  match badge with
  | Some b ->
    let badge_use = (use ~a:(List.append (bounds_attrs badge_bounds) [a_href ("#" ^ b)]) []) in
    badge_use :: l
  | None -> l

let entity_label text_content text_bounds cstyle badge l : node_content_type =
  let text_lines text =
    Str.global_replace (Str.regexp "\\r\\n") "\n" text |> Str.split (Str.regexp "[\r\n]")
  in
  let optional_spacer bo l =
    match bo with
    | Some b -> (
        Html.div ~a:[Html.a_class ["archimate-badge-spacer"]] [];
      ) :: l
    | None -> l
  in
  let name_trimmed : string option =
    match text_content with
    | Some t -> (
        let tn = String.trim t in
        match (String.length tn) with
        | 0 -> None
        | _ -> Some tn
      )
    | None -> None
  in
  let label_style = text_style cstyle in
  match name_trimmed with
  | Some name -> (
      foreignObject ~a:(bounds_attrs text_bounds) [
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
  | None -> l

let conditional_add f_cont f_cond x l =
  match (f_cond x) with
  | true -> List.append [f_cont x] l
  | false -> l

let f_or_zero (f : float option) : float =
  match f with
  | Some v -> v
  | None -> 0.0

let translate_bounds (b : bounds) =
    a_transform [`Translate ((f_or_zero b.x), b.y)]

let rect_badge_bounds b =
  {
    x = Some ((bounds_right b) -. 25.);
    y = Some ((bounds_top b) +. 5.);
    width = 20.;
    height = 20.;
  }

let rect_helper ?(cls=[]) ?(sty="") ?(attrs=[]) b =
  rect ~a:(
    List.concat [
      [
        a_x ((bounds_left b), None);
        a_y ((bounds_top b), None);
        a_width (b.width, None);
        a_height (b.height, None);
        a_class cls;
        a_style sty;
      ]; attrs;]
  ) []


let default_text_bounds b =
  bounds_reduce_by b 2.0

let draw_child t tb sty b bb l =
  List.rev (
    entity_label t tb sty b (
      entity_badge b bb l
    )
  )

let rect_shape (c : child) (e : element_name_type) (dnt : diagram_node_type) =
  let text_bounds = default_text_bounds c.node.bounds in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    rect_helper ~cls:[dnt.background_class] ~sty:(shape_style c.node.style) c.node.bounds;
  ]

let rounded_rect_shape (c : child) (e : element_name_type) (dnt : diagram_node_type) =
  let badge_bounds = {
    x = Some ((bounds_right c.node.bounds) -. 25.);
    y = Some ((bounds_top c.node.bounds) +. 5.);
    width = 20.;
    height = 20.;
  }
  in
  let text_bounds = default_text_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    rect_helper ~cls:[dnt.background_class] ~sty:(shape_style c.node.style) ~attrs:[
      a_rx (5., None);
      a_ry (5., None);
    ] c.node.bounds;
  ]

let group_shape (c : child) (e : element_name_type) (dnt : diagram_node_type) =
  let group_header_height = 21. in
  let bounds = c.node.bounds in
  let text_bounds = { bounds with height = group_header_height; } in
  let group_header_bounds = {
    bounds with
    width = bounds.width /. 2.;
    height = group_header_height;
  }
  in
  let group_body_bounds = {
    bounds with
    y = Some ((bounds_top bounds) +. group_header_height);
    height = bounds.height -. group_header_height;
  }
  in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  let group_style =
    let effective_style =
      match c.node.style with
      | Some sty -> sty
      | None -> { text_alignment = None; fill_color = None; line_color = None;
                  font_color = None; line_width = None; font = None; }
    in
    Some { effective_style with text_alignment = Some 1; }
  in
  draw_child e.name text_bounds group_style dnt.badge badge_bounds [
    rect_helper ~cls:["archimate-decoration"] group_header_bounds;
    rect_helper ~cls:[dnt.background_class] ~sty:(shape_style c.node.style) group_header_bounds;
    rect_helper ~cls:[dnt.background_class] ~sty:(shape_style c.node.style) group_body_bounds;
  ]

let junction_shape c e dnt =
  let text_bounds = default_text_bounds c.node.bounds in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    circle ~a:[
      a_cx (((bounds_left c.node.bounds) +. c.node.bounds.width /. 2.), None);
      a_cy (((bounds_top c.node.bounds) +. c.node.bounds.height /. 2.), None);
      a_r ((c.node.bounds.width /. 2.), None);
      a_class [dnt.background_class];
      a_style (shape_style c.node.style);
    ] []
  ]

let component_shape c e dnt =
  let s_style = shape_style c.node.style in
  let component_decoration left top =
    let decor_bounds = { x = Some left; y = Some top; width = 21.; height = 13.; } in
    [
      rect_helper ~cls:["archimate-decoration"] decor_bounds;
      rect_helper ~cls:[dnt.background_class] ~sty:s_style decor_bounds;
    ]
  in
  let half_decor_width = 21. /. 2. in
  let main_box_x = bounds_left c.node.bounds +. half_decor_width in
  let component_bounds = {
    c.node.bounds with
    x = Some main_box_x;
    width = c.node.bounds.width -. half_decor_width;
  }
  in
  let text_bounds = {
      x = Some (main_box_x +. half_decor_width);
      y = Some ((bounds_top c.node.bounds) +. 1.0);
      width = c.node.bounds.width -. 22.0;
      height = c.node.bounds.height -. 2.0
    }
  in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds (
    List.concat [
      component_decoration (bounds_left c.node.bounds) ((bounds_top c.node.bounds) +. 10.0);
      component_decoration (bounds_left c.node.bounds) ((bounds_top c.node.bounds) +. 30.0);
      [
        rect_helper ~cls:[dnt.background_class] ~sty:s_style component_bounds;
      ];
    ]
  )

let event_shape c e dnt =
  let notch_x = 18. in
  let notch_height = c.node.bounds.height /. 2. in
  let event_width = c.node.bounds.width *. 0.85 in
  let rx = 17. in
  let tb = default_text_bounds c.node.bounds in
  let text_bounds = {
    tb with
    x = Some (bounds_left tb +. (notch_x *. 0.8));
    width = tb.width -. notch_x;
  }
  in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    path ~a:[
      a_d (
        d_of_path [
          MA { x = bounds_left c.node.bounds; y = bounds_top c.node.bounds };
          L { dx = notch_x; dy = notch_height; };
          L { dx = (-. notch_x); dy = notch_height; };
          H { dd = event_width };
          A { rx = rx; ry = notch_height; x_axis_rotate = 0.; large_arc_flag = false; sweep_flag = false; dx = 0.; dy = -. c.node.bounds.height };
          Z;
        ]
      );
      a_class [dnt.background_class];
      a_style (shape_style c.node.style);
    ] [];
  ]

let elipse_shape c e dnt =
  let text_bounds = default_text_bounds c.node.bounds in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    ellipse ~a:[
      a_cx (((bounds_left c.node.bounds) +. c.node.bounds.width /. 2.), None);
      a_cy (((bounds_top c.node.bounds) +. c.node.bounds.height /. 2.), None);
      a_rx ((c.node.bounds.width /. 2.), None);
      a_ry ((c.node.bounds.height /. 2.), None);
      a_class [dnt.background_class];
      a_style (shape_style c.node.style);
    ] [];
  ]

let interface_shape c e dnt =
  let ednt = { dnt with badge = Some "archimate-interface-badge" } in
  match c.node.alt_view with
  | true ->
    rect_shape c e ednt
  | false ->
    elipse_shape c e ednt

let process_path c e dnt =
  let top = bounds_top c.node.bounds in
  let shaft_top = (bounds_top c.node.bounds) +. c.node.bounds.height *. 0.15 in
  let middle = (bounds_top c.node.bounds) +. c.node.bounds.height *. 0.5 in
  let shaft_bottom = (bounds_bottom c.node.bounds) -. c.node.bounds.height *. 0.15 in
  let bottom = bounds_bottom c.node.bounds in
  let left = bounds_left c.node.bounds in
  let arrow_back = (bounds_right c.node.bounds) -. c.node.bounds.height *. 0.5 in
  let right = bounds_right c.node.bounds in
  let text_bounds = bounds_reduce_by {
    x = Some left;
    y = Some shaft_top;
    width = c.node.bounds.width -. c.node.bounds.height *. 0.25;
    height = shaft_bottom -. shaft_top;
  } 2.;
  in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    path ~a:[
      a_d (
        asprintf "M %s %s L %s %s L %s %s L %s %s L %s %s L %s %s L %s %s z"
          (vs left) (vs shaft_top)
          (vs arrow_back) (vs shaft_top)
          (vs arrow_back) (vs top)
          (vs right) (vs middle)
          (vs arrow_back) (vs bottom)
          (vs arrow_back) (vs shaft_bottom)
          (vs left) (vs shaft_bottom)
        );
      a_class [dnt.background_class];
      a_style (shape_style c.node.style);
    ] []
  ]

let process_shape c e dnt =
  match c.node.alt_view with
  | true ->
    process_path c e { dnt with badge = None; }
  | false ->
    rounded_rect_shape c e { dnt with badge = Some "archimate-process-badge"; }

let service_shape c e dnt =
  let text_bounds = {
    x = Some ((bounds_left c.node.bounds) +. 7.);
    y = Some ((bounds_top c.node.bounds) +. 5.);
    width = c.node.bounds.width -. 14.;
    height = c.node.bounds.height -. 10.;
  }
  in
  match c.node.alt_view with
  | true ->
    rect_shape c e { dnt with badge = Some "archimate-service-badge"; }
  | false ->
    let badge_bounds = rect_badge_bounds c.node.bounds in
    draw_child e.name text_bounds c.node.style None badge_bounds [
      rect_helper ~cls:[dnt.background_class] ~sty:(shape_style c.node.style) ~attrs:[
        a_rx ((c.node.bounds.height /. 2.), None);
        a_ry ((c.node.bounds.height /. 2.), None);
      ] c.node.bounds;
    ]

let artifact_shape c e dnt =
  let badge = Some "archimate-artifact-badge" in
  let margin = 18. in
  let sty = shape_style c.node.style in
  let text_bounds = default_text_bounds c.node.bounds in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style badge badge_bounds [
    g ~a:[
      a_class [dnt.background_class];
      a_style sty;
    ] [
      path ~a:[
        a_d (
          asprintf "M %s %s h %s l %s %s v %s h %s z"
            (vs (bounds_left c.node.bounds)) (vs (bounds_top c.node.bounds))
            (vs (c.node.bounds.width -. margin))
            (vs margin) (vs margin)
            (vs (c.node.bounds.height -. margin))
            (vs (-. c.node.bounds.width))
        );
      ] [];
      path ~a:[
        a_d (
          asprintf "M %s %s v %s h %s z"
            (vs ((bounds_right c.node.bounds) -. margin)) (vs (bounds_top c.node.bounds))
            (vs margin)
            (vs margin)
        );
        a_class ["archimate-decoration"];
      ] [];
    ]
  ]

let motivation_shape c e dnt =
  let badge_bounds = {
    x = Some ((bounds_right c.node.bounds) -. 25.);
    y = Some ((bounds_top c.node.bounds) +. 5.);
    width = 20.;
    height = 20.;
  }
  in
  let text_bounds = default_text_bounds c.node.bounds in
  let margin = 10. in
  let width = c.node.bounds.width -. margin *. 2. in
  let height = c.node.bounds.height -. margin *. 2. in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    path ~a:[
      a_d (
        asprintf "M %s %s h %s l %s %s v %s l %s %s h %s l %s %s v %s z"
          (vs ((bounds_left c.node.bounds) +. margin)) (vs (bounds_top c.node.bounds))
          (vs width)
          (vs margin) (vs margin)
          (vs height)
          (vs (-. margin)) (vs margin)
          (vs (-. width))
          (vs (-. margin)) (vs (-. margin))
          (vs (-. height))
      );
      a_class [dnt.background_class];
      a_style (shape_style c.node.style);
    ] [];
  ]

let data_shape c e dnt =
  let margin = 10. in
  let def_tb = default_text_bounds c.node.bounds in
  let text_bounds = {
    def_tb with
    y = Some ((bounds_top def_tb) +. margin);
    height = def_tb.height -. margin;
  }
  in
  let deco_bounds = {
    c.node.bounds with
    height = margin;
  }
  in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    g ~a:[a_class [dnt.background_class]] [
      rect_helper ~cls:[dnt.background_class] ~sty:(shape_style c.node.style) c.node.bounds;
      rect_helper ~cls:["archimate-decoration"] deco_bounds;
    ];
  ]

(* let representation_shape c e dnt = *)
(*           @badge_bounds = child.bounds.with( *)
(*             x: child.bounds.right - 25, *)
(*             y: child.bounds.top + 5, *)
(*             width: 20, *)
(*             height: 20 *)
(*           ) *)
(*         def entity_shape(xml, bounds) *)
(*           representation_path(xml, bounds) *)
(*         end *)

(*         def representation_path(xml, bounds) *)
(*           xml.path( *)
(*             d: [ *)
(*               ["M", bounds.left, bounds.top], *)
(*               ["v", bounds.height - 8], *)
(*               ["c", 0.167 * bounds.width, 0.133 * bounds.height, *)
(*                0.336 * bounds.width, 0.133 * bounds.height, *)
(*                bounds.width * 0.508, 0], *)
(*               ["c", 0.0161 * bounds.width, -0.0778 * bounds.height, *)
(*                0.322 * bounds.width, -0.0778 * bounds.height, *)
(*                bounds.width * 0.475, 0], *)
(*               ["v", -(bounds.height - 8)], *)
(*               "z" *)
(*             ].flatten.join(" "), *)
(*             class: background_class, style: shape_style *)
(*           ) *)
(*         end *)

(* let device_shape c e dnt = *)
(*         include NodeShape *)

(*         def initialize(child,  *)
(*           super *)
(*         end *)

(*         def entity_shape(xml, bounds) *)
(*           case child.child_type *)
(*           when 1 *)
(*             @badge = "#archimate-device-badge" *)
(*             node_path(xml, bounds) *)
(*           else *)
(*             device_path(xml, bounds) *)
(*           end *)
(*         end *)

(*         def device_path(xml, bounds) *)
(*           margin = 10 *)
(*           xml.rect( *)
(*             x: bounds.left, *)
(*             y: bounds.top, *)
(*             width: bounds.width, *)
(*             height: bounds.height - margin, *)
(*             rx: "6", *)
(*             ry: "6", *)
(*             class: background_class, *)
(*             style: shape_style *)
(*           ) *)
(*           decoration_path = [ *)
(*             "M", bounds.left + margin, bounds.bottom - margin, *)
(*             "l", -margin, margin, *)
(*             "h", bounds.width, *)
(*             "l", -margin, -margin, *)
(*             "z" *)
(*           ].flatten.join(" ") *)
(*           xml.path(d: decoration_path, class: background_class, style: shape_style) *)
(*           xml.path(d: decoration_path, class: "archimate-decoration", style: shape_style) *)
(*         end *)
(*       end *)
(*     end *)

(* let meaning_shape = *)
(*           def entity_shape(xml, bounds) *)
(*           meaning_path(xml, bounds) *)
(*         end *)

(*         def meaning_path(xml, bounds) *)
(*           pts = [ *)
(*             Point.new(bounds.left + bounds.width * 0.04, bounds.top + bounds.height * 0.5), *)
(*             Point.new(bounds.left + bounds.width * 0.5, bounds.top + bounds.height * 0.12), *)
(*             Point.new(bounds.left + bounds.width * 0.94, bounds.top + bounds.height * 0.55), *)
(*             Point.new(bounds.left + bounds.width * 0.53, bounds.top + bounds.height * 0.87) *)
(*           ] *)
(*           xml.path( *)
(*             d: [ *)
(*               "M", pts[0].x, pts[0].y, *)
(*               "C", pts[0].x - bounds.width * 0.15, pts[0].y - bounds.height * 0.32, *)
(*               pts[1].x - bounds.width * 0.3, pts[1].y - bounds.height * 0.15, *)
(*               pts[1].x, pts[1].y, *)
(*               "C", pts[1].x + bounds.width * 0.29, pts[1].y - bounds.height * 0.184, *)
(*               pts[2].x + bounds.width * 0.204, pts[2].y - bounds.height * 0.304, *)
(*               pts[2].x, pts[2].y, *)
(*               "C", pts[2].x + bounds.width * 0.028, pts[2].y + bounds.height * 0.295, *)
(*               pts[3].x + bounds.width * 0.156, pts[3].y + bounds.height * 0.088, *)
(*               pts[3].x, pts[3].y, *)
(*               "C", pts[3].x - bounds.width * 0.279, pts[3].y + bounds.height * 0.326, *)
(*               pts[0].x - bounds.width * 0.164, pts[0].y + bounds.height * 0.314, *)
(*               pts[0].x, pts[0].y *)
(*             ].flatten.join(" "), *)
(*             class: background_class, style: shape_style *)
(*           ) *)
(*         end *)
(*       end *)

(* let node_shape = *)
(*           def entity_shape(xml, bounds) *)
(*           case child.child_type *)
(*           when 1 *)
(*             @badge_bounds = bounds.with( *)
(*               x: bounds.right - 25, *)
(*               y: bounds.top + 5, *)
(*               width: 20, *)
(*               height: 20 *)
(*             ) *)
(*             @badge = "#archimate-node-badge" *)
(*             rect_path(xml, bounds) *)
(*           else *)
(*             node_path(xml, bounds) *)
(*           end *)
(* end *)
(*         def node_path(xml, bounds) *)
(*           margin = 14 *)
(*           @badge_bounds = DataModel::Bounds.new( *)
(*             x: bounds.right - margin - 25, *)
(*             y: bounds.top + margin + 5, *)
(*             width: 20, *)
(*             height: 20 *)
(*           ) *)
(*           node_box_height = bounds.height - margin *)
(*           node_box_width = bounds.width - margin *)
(*           @text_bounds = DataModel::Bounds.new( *)
(*             x: bounds.left + 1, *)
(*             y: bounds.top + margin + 1, *)
(*             width: node_box_width - 2, *)
(*             height: node_box_height - 2 *)
(*           ) *)
(*           xml.g(class: background_class, style: shape_style) do *)
(*             xml.path( *)
(*               d: [ *)
(*                 ["M", bounds.left, bounds.bottom], *)
(*                 ["v", -node_box_height], *)
(*                 ["l", margin, -margin], *)
(*                 ["h", node_box_width], *)
(*                 ["v", node_box_height], *)
(*                 ["l", -margin, margin], *)
(*                 "z" *)
(*               ].flatten.join(" ") *)
(*             ) *)
(*             xml.path( *)
(*               d: [ *)
(*                 ["M", bounds.left, bounds.top + margin], *)
(*                 ["l", margin, -margin], *)
(*                 ["h", node_box_width], *)
(*                 ["v", node_box_height], *)
(*                 ["l", -margin, margin], *)
(*                 ["v", -node_box_height], *)
(*                 "z", *)
(*                 ["M", bounds.right, bounds.top], *)
(*                 ["l", -margin, margin] *)
(*               ].flatten.join(" "), *)
(*               class: "archimate-decoration" *)
(*             ) *)
(*             xml.path( *)
(*               d: [ *)
(*                 ["M", bounds.left, bounds.top + margin], *)
(*                 ["h", node_box_width], *)
(*                 ["l", margin, -margin], *)
(*                 ["M", bounds.left + node_box_width, bounds.bottom], *)
(*                 ["v", -node_box_height] *)
(*               ].flatten.join(" "), *)
(*               style: "fill:none;stroke:inherit;" *)
(*             ) *)
(*           end *)
(*         end *)

let note_shape c e dnt =
  let text_bounds = default_text_bounds c.node.bounds in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  let bounds = c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    path ~a:[
      a_d (
        asprintf "m %s %s h %s v %s l %s %s h %s z"
          (vs (bounds_left bounds)) (vs (bounds_top bounds))
          (vs bounds.width)
          (vs (bounds.height -. 8.))
          "-8" "8"
          (vs (-. (bounds.width -. 8.)))
      );
      a_class ["archimate-note-background"];
      a_style (shape_style c.node.style);
    ] [];
  ]

let product_shape c e dnt =
  let text_bounds = default_text_bounds c.node.bounds in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    g ~a:[a_class [dnt.background_class]] [
      rect_helper ~cls:[dnt.background_class] ~sty:(shape_style c.node.style) c.node.bounds;
      rect_helper ~cls:["archimate-decoration"] {
        c.node.bounds with
        width = c.node.bounds.width /. 2.;
        height = 8.;
      };
    ]
  ]

let value_shape c e dnt =
  let def_tb = default_text_bounds c.node.bounds in
  let text_bounds = {
    x = Some ((bounds_left def_tb) +. 10.);
    y = Some ((bounds_top def_tb) +. 10.);
    width = def_tb.width -. 20.;
    height = def_tb.height -. 20.;
  }
  in
  let bounds = c.node.bounds in
  let cx = (bounds_left bounds) +. bounds.width /. 2. in
  let rx = bounds.width /. 2. -. 1. in
  let cy = (bounds_top bounds) +. bounds.height /. 2. in
  let ry = bounds.height /. 2. -. 1. in
  let badge_bounds = rect_badge_bounds c.node.bounds in
  draw_child e.name text_bounds c.node.style dnt.badge badge_bounds [
    ellipse ~a:[
      a_cx (cx, None);
      a_cy (cy, None);
      a_rx (rx, None);
      a_ry (ry, None);
      a_class [dnt.background_class];
      a_style (shape_style c.node.style)
    ] [];
  ]


let child_diagram_node_type c e =
  let layer_background_class = function
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
  | BusinessEvent -> { default_diagram_node_type with g_class = "archimate-business-event"; entity_shape = event_shape; }
  | BusinessFunction  -> { default_diagram_node_type with g_class = "archimate-business-function"; badge = Some "archimate-function-badge"; entity_shape = rounded_rect_shape; }
  | BusinessInteraction -> { default_diagram_node_type with g_class = "archimate-business-interaction"; badge = Some "archimate-interaction-badge"; entity_shape = rounded_rect_shape; }
  | BusinessInterface -> { default_diagram_node_type with g_class = "archimate-business-interface"; badge = Some "archimate-interface-badge"; entity_shape = interface_shape; }
  | BusinessObject -> { default_diagram_node_type with g_class = "archimate-business-object"; }
  | BusinessProcess -> { default_diagram_node_type with g_class = "archimate-business-process"; badge = Some "archimate-process-badge"; }
  | BusinessRole -> { default_diagram_node_type with g_class = "archimate-business-role"; badge = Some "archimate-role-badge"; }
  | BusinessService -> { default_diagram_node_type with g_class = "archimate-business-service"; badge = Some "archimate-service-badge"; entity_shape = service_shape; }
  | Contract -> { default_diagram_node_type with g_class = "archimate-contract"; }
  | Meaning -> { default_diagram_node_type with g_class = "archimate-meaning"; }
  | Product -> { default_diagram_node_type with g_class = "archimate-product"; }
  | Representation -> { default_diagram_node_type with g_class = "archimate-representation"; }
  | Value -> { default_diagram_node_type with g_class = "archimate-value"; }
  | ApplicationCollaboration -> { default_diagram_node_type with g_class = "archimate-application-collaboration"; badge = Some "archimate-collaboration-badge"; }
  | ApplicationComponent -> { default_diagram_node_type with g_class = "archimate-application-component"; entity_shape = component_shape; }
  | ApplicationFunction -> { default_diagram_node_type with g_class = "archimate-application-function"; badge = Some "archimate-function-badge"; entity_shape = rounded_rect_shape; }
  | ApplicationInteraction -> { default_diagram_node_type with g_class = "archimate-application-interaction"; badge = Some "archimate-interaction-badge"; entity_shape = rounded_rect_shape; }
  | ApplicationInterface -> { default_diagram_node_type with g_class = "archimate-application-interface"; badge = Some "archimate-interface-badge"; entity_shape = interface_shape; }
  | ApplicationService -> { default_diagram_node_type with g_class = "archimate-application-service"; badge = Some "archimate-service-badge"; entity_shape = service_shape; }
  | DataObject -> { default_diagram_node_type with g_class = "archimate-data-object"; }
  | Artifact -> { default_diagram_node_type with g_class = "archimate-artifact"; entity_shape = artifact_shape; }
  | CommunicationPath -> { default_diagram_node_type with g_class = "archimate-communication-path"; badge = Some "archimate-communication-badge"; }
  | Device -> { default_diagram_node_type with g_class = "archimate-device"; badge = Some "archimate-device-badge"; }
  | InfrastructureFunction -> { default_diagram_node_type with g_class = "archimate-infrastructure-function"; badge = Some "archimate-function-badge"; entity_shape = rounded_rect_shape; }
  | InfrastructureInterface -> { default_diagram_node_type with g_class = "archimate-infrastructure-interface"; badge = Some "archimate-interface-badge"; entity_shape = interface_shape; }
  | InfrastructureService -> { default_diagram_node_type with g_class = "archimate-infrastructure-service"; badge = Some "archimate-service-badge"; entity_shape = service_shape; }
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
  | WorkPackage -> { default_diagram_node_type with g_class = "archimate-work-package"; entity_shape = rounded_rect_shape; }
  | DiagramModelReference -> { default_diagram_node_type with g_class = "archimate-diagram-model-reference"; badge = Some "archimate-diagram-model-reference-badge"; }
  | Group -> { default_diagram_node_type with g_class = "archimate-group"; entity_shape = group_shape; }
  | DiagramObject -> { default_diagram_node_type with g_class = "archimate-diagram-object"; }
  | Note -> { default_diagram_node_type with g_class = "archimate-note"; entity_shape = note_shape; background_class = "archimate-note-background"; }
  | SketchModelSticky -> { default_diagram_node_type with g_class = "archimate-sketch-model-sticky"; }

(* TODO: Transform only needed only for Archi file types *)
let group_attrs e g_class bounds_offset =
  let add_bounds bo l =
    match bo with
    | Some b -> (translate_bounds b) :: l
    | None -> l
  in
  add_bounds bounds_offset [
    a_id e.id;
    a_class [g_class];
  ]

let rec to_svg m bounds_offset (c : child) =
  let e = effective_child_element c m in
  let dnt = child_diagram_node_type c e in
  let add_title e l =
    match e.name with
    | Some name -> (title (pcdata name) :: l)
    | None -> l
  in
  let add_desc c l =
    match (List.length c.documentation) with
    | 0 -> l
    | _ ->
      (desc (pcdata (String.concat "\n\n" (List.map (fun doc -> doc.content) c.documentation)))) :: l
  in
  let title_dest c e =
    add_title e (
      add_desc c []
    )
  in
  g ~a:(group_attrs e dnt.g_class bounds_offset) (
    List.concat [
      title_dest c e;
      dnt.entity_shape c e dnt;
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
  let contents = List.map (Format.asprintf "%a\n" (pp_elt ())) (List.concat [els; rels])
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
  (* pp () (diagram_to_svg m d); *)
  fprintf fmt "%s" (diagram_to_svg m d);
  close_out svg_file

let svgs outdir (m : model) =
  List.iter (export outdir m) m.node.diagrams

