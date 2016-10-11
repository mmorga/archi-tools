open OUnit2;;

(* Name the test cases and group them together *)
let () =
  run_test_tt_main
    ~exit
    ("ArchiMate" >:::
      [
        TestArchimate.tests;
        TestXmlUtil.tests;
      ]
    );
