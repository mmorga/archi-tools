open OUnit2
open Color

let tests =
  "Color" >:::
  [
    "black" >::
    (fun test_ctxt ->
      assert_equal { Color.r = 0; Color.g = 0; Color.b = 0; Color.a = None } Color.black
    )
  ]
