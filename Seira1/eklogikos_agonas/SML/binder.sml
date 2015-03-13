use "agonas_ianos.sml"
let
val l = agonas "tests/test7.in"
in
use "printer.sml"
printList (fn x => Int.toString x) l
end
