fun printList f ls file =
    let
      val outfile = TextIO.openOut file
    in
      TextIO.output (outfile, (String.concatWith " " (map f ls)) ^ "\n")
    end
	
	(* Καλείς ως printList Int.toString <λίστα_που_θές>
    * <αρχείο_να_στείλει_την_έξοδο> *)
