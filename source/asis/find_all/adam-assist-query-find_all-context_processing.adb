with
     Ada.Wide_Text_IO,
     Ada.Characters.Handling,
     Ada.Exceptions,

     Asis.Compilation_Units,
     Asis.Exceptions,
     Asis.Errors,
     Asis.Implementation,

     AdaM.Assist.Query.find_All.unit_Processing;


package body AdaM.Assist.Query.find_All.context_Processing
is
   function Get_Unit_From_File_Name (Ada_File_Name : String;
                                     The_Context   : Asis.Context) return Asis.Compilation_Unit
   is
   begin
      return Asis.Nil_Compilation_Unit;
   end Get_Unit_From_File_Name;


   procedure Process_Context (The_Context : Asis.Context;
                              Trace       : Boolean     := False)
   is
      Units : constant Asis.Compilation_Unit_List :=
         Asis.Compilation_Units.Compilation_Units (The_Context);

      Next_Unit        : Asis.Compilation_Unit := Asis.Nil_Compilation_Unit;
      Next_Unit_Origin : Asis.Unit_Origins     := Asis.Not_An_Origin;
      Next_Unit_Class  : Asis.Unit_Classes     := Asis.Not_A_Class;

   begin
      for J in Units'Range
      loop
         Next_Unit        := Units (J);
         Next_Unit_Class  := Asis.Compilation_Units.Unit_Class (Next_Unit);
         Next_Unit_Origin := Asis.Compilation_Units.Unit_Origin (Next_Unit);

         case Next_Unit_Origin is
            when Asis.An_Application_Unit
               | Asis.A_Predefined_Unit =>
               AdaM.Assist.Query.find_All.unit_Processing.Process_Unit (Next_Unit);
               --  This is the call to the procedure which performs the
               --  analysis of a particular unit

            when Asis.An_Implementation_Unit =>
               if Trace then
                  Ada.Wide_Text_IO.Put
                    ("Skipped as an implementation-defined unit");
               end if;

            when Asis.Not_An_Origin =>
               if Trace then
                  Ada.Wide_Text_IO.Put
                    ("Skipped as nonexistent unit");
               end if;
         end case;
      end loop;

   exception
      --  The exception handling in this procedure is somewhat redundant and
      --  may need some reconsidering when using this procedure as a template
      --  for a real ASIS tool

      when Ex : Asis.Exceptions.ASIS_Inappropriate_Context          |
                Asis.Exceptions.ASIS_Inappropriate_Container        |
                Asis.Exceptions.ASIS_Inappropriate_Compilation_Unit |
                Asis.Exceptions.ASIS_Inappropriate_Element          |
                Asis.Exceptions.ASIS_Inappropriate_Line             |
                Asis.Exceptions.ASIS_Inappropriate_Line_Number      |
                Asis.Exceptions.ASIS_Failed                         =>

         Ada.Wide_Text_IO.Put ("Process_Context : ASIS exception (");

         Ada.Wide_Text_IO.Put (Ada.Characters.Handling.To_Wide_String (
                 Ada.Exceptions.Exception_Name (Ex)));

         Ada.Wide_Text_IO.Put (") is raised when processing unit ");

         Ada.Wide_Text_IO.Put
            (Asis.Compilation_Units.Unit_Full_Name (Next_Unit));

         Ada.Wide_Text_IO.New_Line;

         Ada.Wide_Text_IO.Put ("ASIS Error Status is ");

         Ada.Wide_Text_IO.Put
           (Asis.Errors.Error_Kinds'Wide_Image (Asis.Implementation.Status));

         Ada.Wide_Text_IO.New_Line;

         Ada.Wide_Text_IO.Put ("ASIS Diagnosis is ");
         Ada.Wide_Text_IO.New_Line;
         Ada.Wide_Text_IO.Put (Asis.Implementation.Diagnosis);
         Ada.Wide_Text_IO.New_Line;

         Asis.Implementation.Set_Status;

      when Ex : others =>

         Ada.Wide_Text_IO.Put ("Process_Context : ");

         Ada.Wide_Text_IO.Put (Ada.Characters.Handling.To_Wide_String (
                 Ada.Exceptions.Exception_Name (Ex)));

         Ada.Wide_Text_IO.Put (" is raised (");

         Ada.Wide_Text_IO.Put (Ada.Characters.Handling.To_Wide_String (
                 Ada.Exceptions.Exception_Information (Ex)));

         Ada.Wide_Text_IO.Put (")");
         Ada.Wide_Text_IO.New_Line;

         Ada.Wide_Text_IO.Put ("when processing unit");

         Ada.Wide_Text_IO.Put
            (Asis.Compilation_Units.Unit_Full_Name (Next_Unit));

         Ada.Wide_Text_IO.New_Line;

   end Process_Context;

end AdaM.Assist.Query.find_All.context_Processing;
