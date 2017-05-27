with asis.Elements,
     asis.Compilation_Units,

     AdaM.compilation_Unit,
     AdaM.library_Item,
     AdaM.library_Unit.declaration,

     AdaM.Assist.Query.find_Entities.element_Processing,
     AdaM.Assist.Query.find_Entities.Metrics,

     Ada.Characters.Handling;
with Ada.Text_IO; use Ada.Text_IO;


package body AdaM.Assist.Query.find_Entities.unit_Processing
is

   procedure Process_Unit (The_Unit : Asis.Compilation_Unit)
   is
      use Asis, ada.Characters.Handling;

      Cont_Clause_Elements : constant Asis.Element_List
        := Asis.Elements.Context_Clause_Elements (Compilation_Unit => The_Unit,
                                                  Include_Pragmas  => True);
      --  This is the list of the context clauses, including pragmas, if any.
      --  If you do not want to process pragmas, set Include_Pragmas OFF when
      --  calling Asis.Elements.Context_Clause_Elements.

      Unit_Decl : constant Asis.Element := Asis.Elements.Unit_Declaration (The_Unit);
      --  The top-level structural element of the library item or subunit
      --  contained in The_Unit.

      the_Name : constant String          := to_String (asis.Compilation_Units.Unit_Full_Name (The_Unit));
      Kind     : constant asis.Unit_Kinds := asis.Compilation_Units.Unit_Kind (the_Unit);

   begin
--        Metrics.new_Unit := adam.compilation_Unit.new_Unit ("anon");
      put_Line ("Processing compilation unit    ***" & the_Name & "***  of kind " & asis.Unit_Kinds'Image (Kind));

      if Kind = asis.a_Package
      then
         Metrics.current_compilation_Unit := AdaM.compilation_Unit.new_compilation_Unit;
--             := adam.compilation_Unit.new_library_Unit
--                  (the_Name,
--                   library_Item.new_Item (adam.library_Unit.declaration.new_Package.all'Access));
--
--           Metrics.current_package_Declaration
--             := AdaM.library_Unit.declaration.view (Metrics.current_compilation_Unit.library_Item.Unit).my_Package;
      end if;




      Metrics.compilation_Unit.clear;
      Metrics.compilation_Unit.Name_is (the_Name);

      for J in Cont_Clause_Elements'Range
      loop
         AdaM.Assist.Query.find_Entities.element_Processing.Process_Construct (Cont_Clause_Elements (J));
      end loop;

      AdaM.Assist.Query.find_Entities.element_Processing.Process_Construct (Unit_Decl);

      --  This procedure does not contain any exception handler because it
      --  supposes that Element_Processing.Process_Construct should handle
      --  all the exceptions which can be raised when processing the element
      --  hierarchy.

--        declare
--           new_Unit : constant AdaM.compilation_Unit.view
--             := AdaM.compilation_Unit.new_Unit (Name    => "",
--                                                of_Kind => compilation_Unit.library_unit_Kind);
--        begin
--           AdaM.compilation_Unit.item (new_Unit.all) := Metrics.compilation_Unit;
--           Metrics.Environment.add (new_Unit);
--        end;

      declare
         new_Unit : constant AdaM.compilation_Unit.view := AdaM.compilation_Unit.new_compilation_Unit;
      begin
         AdaM.compilation_Unit.item (new_Unit.all) := Metrics.compilation_Unit;
         Metrics.Environment.add (new_Unit);
      end;


      put_Line ("End of processing compilation unit    ***" & the_Name & "***  of kind " & asis.Unit_Kinds'Image (Kind));
      new_Line (2);
   end Process_Unit;

end AdaM.Assist.Query.find_Entities.unit_Processing;
