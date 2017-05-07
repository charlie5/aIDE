with asis.Elements,
     asis.Compilation_Units,

     adam.compilation_Unit,
     adam.Assist.Query.find_All.element_Processing,
     adam.Assist.Query.find_All.Metrics,

     Ada.Characters.Handling;


package body adam.Assist.Query.find_All.unit_Processing
is

   procedure Process_Unit (The_Unit : Asis.Compilation_Unit)
   is
      Cont_Clause_Elements : constant Asis.Element_List
        := Asis.Elements.Context_Clause_Elements (Compilation_Unit => The_Unit,
                                                  Include_Pragmas  => True);
      --  This is the list of the context clauses, including pragmas, if any.
      --  If you do not want to process pragmas, set Include_Pragmas OFF when
      --  calling Asis.Elements.Context_Clause_Elements.

      Unit_Decl : constant Asis.Element := Asis.Elements.Unit_Declaration (The_Unit);
      --  The top-level structural element of the library item or subunit
      --  contained in The_Unit.

   begin
      Metrics.compilation_Unit.clear;
      Metrics.compilation_Unit.Name_is (ada.Characters.Handling.to_String (asis.Compilation_Units.Unit_Full_Name (The_Unit)));

      for J in Cont_Clause_Elements'Range
      loop
         adam.Assist.Query.find_All.element_Processing.Process_Construct (Cont_Clause_Elements (J));
      end loop;

      adam.Assist.Query.find_All.element_Processing.Process_Construct (Unit_Decl);

      --  This procedure does not contain any exception handler because it
      --  supposes that Element_Processing.Process_Construct should handle
      --  all the exceptions which can be raised when processing the element
      --  hierarchy.

      declare
         new_Unit : constant adam.compilation_Unit.view := adam.compilation_Unit.new_Unit (Name => "");
      begin
         adam.compilation_Unit.item (new_Unit.all) := Metrics.compilation_Unit;
         Metrics.Environment.add (new_Unit);
      end;
   end Process_Unit;

end adam.Assist.Query.find_All.unit_Processing;
