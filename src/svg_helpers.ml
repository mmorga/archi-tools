open Format

module Path =
struct
  type abs_point = {
    x : float;
    y : float;
  }

  type relative_point = {
    dx : float;
    dy : float;
  }

  type abs_arc_to = {
    rx : float;
    ry : float;
    x_axis_rotate : float;
    large_arc_flag : bool;
    sweep_flag : bool;
    x : float;
    y : float;
  }

  type relative_arc_to = {
    rx : float;
    ry : float;
    x_axis_rotate : float;
    large_arc_flag : bool;
    sweep_flag : bool;
    dx : float;
    dy : float;
  }

  type abs_dist = {
    d : float;
  }

  type relative_dist = {
    dd : float;
  }

  type abs_curve = {
    c1x : float;
    c1y : float;
    c2x : float;
    c2y : float;
    x : float;
    y : float;
  }

  type relative_curve = {
    dc1x : float;
    dc1y : float;
    dc2x : float;
    dc2y : float;
    dx : float;
    dy : float;
  }

  type abs_quadratic_bezier_curve = {
    cx : float;
    cy : float;
    x : float;
    y : float;
  }

  type relative_quadratic_bezier_curve = {
    dcx : float;
    dcy : float;
    dx : float;
    dy : float;
  }

  type path_element =
      A of relative_arc_to
    | AA of abs_arc_to
    | H of relative_dist
    | HA of abs_dist
    | L of relative_point
    | LA of abs_point
    | M of relative_point
    | MA of abs_point
    | C of relative_curve
    | CA of abs_curve
    | Q of relative_quadratic_bezier_curve
    | QA of abs_quadratic_bezier_curve
    | S of relative_quadratic_bezier_curve
    | SA of abs_quadratic_bezier_curve
    | T of relative_point
    | TA of abs_point
    | V of relative_dist
    | VA of abs_dist
    | Z

  type path = path_element list

  let vs v =
    let fr, iv = modf v in
    match fr with
    | 0. -> asprintf "%d" (int_of_float iv)
    | _ ->
      let re = Str.regexp "0+$" in
      Str.global_replace re "" (asprintf "%f" v)

  let bs b =
    match b with
    | false -> "0"
    | true -> "1"

  let string_of_path_element pe =
    match pe with
    | A a ->
      asprintf "a %s %s %s %s %s %s %s" (vs a.rx) (vs a.ry) (vs a.x_axis_rotate)
        (bs a.large_arc_flag) (bs a.sweep_flag) (vs a.dx) (vs a.dy)
    | AA a ->
      asprintf "A %s %s %s %s %s %s %s" (vs a.rx) (vs a.ry) (vs a.x_axis_rotate)
        (bs a.large_arc_flag) (bs a.sweep_flag) (vs a.x) (vs a.y)
    | H d ->
      asprintf "h %s" (vs d.dd)
    | HA d ->
      asprintf "H %s" (vs d.d)
    | L p ->
      asprintf "l %s %s" (vs p.dx) (vs p.dy)
    | LA p ->
      asprintf "L %s %s" (vs p.x) (vs p.y)
    | M p ->
      asprintf "m %s %s" (vs p.dx) (vs p.dy)
    | MA p ->
      asprintf "M %s %s" (vs p.x) (vs p.y)
    | C c ->
      asprintf "c %s,%s %s,%s %s,%s" (vs c.dc1x) (vs c.dc1y) (vs c.dc2x) (vs c.dc2y) (vs c.dx) (vs c.dy)
    | CA c ->
      asprintf "C %s,%s %s,%s %s,%s" (vs c.c1x) (vs c.c1y) (vs c.c2x) (vs c.c2y) (vs c.x) (vs c.y)
    | Q q ->
      asprintf "q %s,%s %s,%s" (vs q.dcx) (vs q.dcy) (vs q.dx) (vs q.dy)
    | QA q ->
      asprintf "Q %s,%s %s,%s" (vs q.cx) (vs q.cy) (vs q.x) (vs q.y)
    | S q ->
      asprintf "s %s,%s %s,%s" (vs q.dcx) (vs q.dcy) (vs q.dx) (vs q.dy)
    | SA q ->
      asprintf "S %s,%s %s,%s" (vs q.cx) (vs q.cy) (vs q.x) (vs q.y)
    | T p ->
      asprintf "t %s %s" (vs p.dx) (vs p.dy)
    | TA p ->
      asprintf "T %s %s" (vs p.x) (vs p.y)
    | V d ->
      asprintf "v %s" (vs d.dd)
    | VA d ->
      asprintf "V %s" (vs d.d)
    | Z ->
      "z"

  let d_of_path p =
    List.map string_of_path_element p |> String.concat " "

end
