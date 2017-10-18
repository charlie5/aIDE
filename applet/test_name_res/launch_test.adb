with
     Libadalang.Analysis,
     Ada.Text_IO;

procedure launch_Test
is
   use Ada.Text_IO;
   package LAL renames Libadalang.Analysis;

   Ctx  : LAL.Analysis_Context := LAL.Create;
   Unit : LAL.Analysis_Unit    := LAL.Get_From_File (Ctx, "test_package.ads", With_Trivia => False);
begin
   LAL.Print (Unit);
   LAL.Populate_Lexical_Env (Unit);

   declare
      Node  : LAL.Ada_Node := LAL.Root (Unit);
      Dummy : Boolean;
   begin
      Dummy := Node.P_Resolve_Symbols;

--        process (Node);
      new_Line (2);
      put_Line ("Node");
   end;

   LAL.Destroy (Ctx);
end launch_Test;

