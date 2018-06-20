open OUnit2
open Color

let tests =
  "Color" >:::
  [
    "black" >::
    (fun test_ctxt ->
      assert_equal { Color.r = 0; Color.g = 0; Color.b = 0; Color.a = None } Color.black
    );

    "create" >:::
      [
        "success with alpha" >::
        (fun test_ctxt ->
          assert_equal
            { Color.r = 0x33; Color.g = 0xff; Color.b = 0; Color.a = Some 50 }
            (Color.create 0x33 0xff 0 (Some 50))
        );

        "success without alpha" >::
        (fun test_ctxt ->
          assert_equal
            { Color.r = 0x33; Color.g = 0xff; Color.b = 0; Color.a = None }
            (Color.create 0x33 0xff 0 None)
        );

        "failure red" >::
        (fun test_ctxt ->
          assert_raises
            (Color.ValueError "Color attribute outside of range")
            (fun () -> Color.create 0x100 0xff 0 None)
        );

        "failure green" >::
        (fun test_ctxt ->
          assert_raises
            (Color.ValueError "Color attribute outside of range")
            (fun () -> Color.create 0 (-1) 0 None)
        );

        "failure blue" >::
        (fun test_ctxt ->
          assert_raises
            (Color.ValueError "Color attribute outside of range")
            (fun () -> Color.create 0 0 256 None)
        );

        "failure alpha" >::
        (fun test_ctxt ->
          assert_raises
            (Color.ValueError "Color attribute outside of range")
            (fun () -> Color.create 0 0 0 (Some 101))
        );

      ];

    "rgba" >:::
      [
        "no string" >::
        (fun test_ctxt ->
          assert_equal None (Color.rgba None)
        );

        "invalid string" >::
        (fun test_ctxt ->
          assert_equal None (Color.rgba (Some "Blood Red"))
        );

        "#aa1122ff" >::
        (fun test_ctxt ->
          assert_equal (Some { Color.r = 0xaa; Color.g = 0x11; Color.b = 0x22; Color.a = Some 100 }) (Color.rgba (Some "#aa112264"))
        );

        "#aa1122" >::
        (fun test_ctxt ->
          assert_equal (Some { Color.r = 0xaa; Color.g = 0x11; Color.b = 0x22; Color.a = None }) (Color.rgba (Some "#aa1122"))
        );

        "#aB2" >::
        (fun test_ctxt ->
          assert_equal (Some { Color.r = 0xaa; Color.g = 0xbb; Color.b = 0x22; Color.a = None }) (Color.rgba (Some "#aB2"))
        );

        "#aB21" >::
        (fun test_ctxt ->
          assert_equal (Some { Color.r = 0xaa; Color.g = 0xbb; Color.b = 0x22; Color.a = Some 0x11 }) (Color.rgba (Some "#aB21"))
        );
      ];
  ]
