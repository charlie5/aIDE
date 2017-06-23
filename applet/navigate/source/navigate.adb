with
     AdaM.Environment,
     AdaM.a_Type.enumeration_type,
     AdaM.a_Type.signed_integer_type,
     AdaM.a_Type.a_subtype;

with Ada.Characters.Handling;
with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;

with Langkit_Support.Diagnostics;
with Langkit_Support.Text;
with Libadalang.Analysis;

with Put_Title;
with AdaM.compilation_Unit;
with AdaM.Declaration.of_package;
with AdaM.a_Package;

procedure Navigate
is
   Environ : AdaM.Environment.item;

   package CMD renames Ada.Command_Line;
   package LAL renames Libadalang.Analysis;

   function Short_Image (Node : access LAL.Ada_Node_Type'Class) return String
   is (Langkit_Support.Text.Image (Node.Short_Image));

   function To_Lower (S : String) return String
      renames Ada.Characters.Handling.To_Lower;

   Fatal_Error   : exception;
   Ctx           : LAL.Analysis_Context;
   Enabled_Kinds : array (LAL.Ada_Node_Kind_type) of Boolean :=
     (others => True);

   function Is_Navigation_Disabled (N : LAL.Ada_Node) return Boolean;

   function Node_Filter (N : LAL.Ada_Node) return Boolean
   is
     (Enabled_Kinds (N.Kind) and then not Is_Navigation_Disabled (N));

   procedure Stop_With_Error (Message    : String);

   procedure Process_File (Unit : LAL.Analysis_Unit; Filename : String);

   procedure Print_Navigation (Part_Name  : String;
                               Orig, Dest : access LAL.Ada_Node_Type'Class);

   procedure Decode_Kinds (List : String);

   ---------------------
   -- Stop_With_Error --
   ---------------------

   procedure Stop_With_Error (Message    : String)
   is
   begin
      Put_Line (CMD.Command_Name & ": " & Message);
      raise Fatal_Error;
   end Stop_With_Error;


   ------------------
   -- Process_File --
   ------------------

   procedure Process_File (Unit : LAL.Analysis_Unit; Filename : String) is
   begin
      if LAL.Has_Diagnostics (Unit) then
         for D of LAL.Diagnostics (Unit) loop
            Put_Line ("error: " & Filename & ": "
                      & Langkit_Support.Diagnostics.To_Pretty_String (D));
         end loop;
         New_Line;
         return;
      end if;

      LAL.Populate_Lexical_Env (Unit);

      declare
         It            : LAL.Local_Find_Iterator :=
            LAL.Root (Unit).Find (Node_Filter'Access);
         Node          : LAL.Ada_Node;
         At_Least_Once : Boolean := False;
      begin
         while It.Next (Node) loop
            declare
               Processed_Something : Boolean := True;
            begin
               case Node.Kind is

                  --  Packages

                  when LAL.Ada_Base_Package_Decl =>

                     Print_Navigation
                       ("Body", Node,
                        LAL.Base_Package_Decl (Node).P_Body_Part);
                  when LAL.Ada_Package_Body =>
                     Print_Navigation
                       ("Decl", Node, LAL.Package_Body (Node).P_Decl_Part);

                  when LAL.Ada_Generic_Package_Decl =>
                     Print_Navigation
                       ("Body", Node,
                        LAL.Generic_Package_Decl (Node).P_Body_Part);

                  --  Subprograms

                  when LAL.Ada_Subp_Decl =>
                     Print_Navigation
                       ("Body", Node, LAL.Subp_Decl (Node).P_Body_Part);
                  when LAL.Ada_Subp_Body =>
                     Print_Navigation
                       ("Decl", Node, LAL.Subp_Body (Node).P_Decl_Part);

                  when LAL.Ada_Generic_Subp_Decl =>
                     Print_Navigation
                       ("Body", Node,
                        LAL.Generic_Subp_Decl (Node).P_Body_Part);

                  when others =>
                     Put_Line ("Skip processing of " & Short_Image (Node));
                     Processed_Something := False;

               end case;
               At_Least_Once := At_Least_Once or else Processed_Something;
            exception
               when LAL.Property_Error =>
                  Put_Line ("Error when processing " & Short_Image (Node));
                  At_Least_once := True;
            end;
         end loop;
         if not At_Least_Once then
            Put_Line ("<no node to process>");
         end if;
            New_Line;
      end;
   end Process_File;

   ----------------------
   -- Print_Navigation --
   ----------------------

   procedure Print_Navigation
     (Part_Name : String; Orig, Dest : access LAL.Ada_Node_Type'Class) is
   begin
      if Dest = null then
         Put_Line
           (Short_Image (Orig) & " has no " & To_Lower (Part_Name));
      else
         Put_Line
           (Part_Name & " of " & Short_Image (Orig) & " is "
            & Short_Image (Dest)
            & " [" & LAL.Get_Filename (Dest.Get_Unit) & "]");
      end if;
   end Print_Navigation;

   ------------------
   -- Decode_Kinds --
   ------------------

   procedure Decode_Kinds (List : String) is
      Start : Positive := List'First;

      procedure Process_Name (Name : String);

      ------------------
      -- Process_Name --
      ------------------

      procedure Process_Name (Name : String) is
      begin
         if Name'Length /= 0 then
            begin
               declare
                  Kind : constant LAL.Ada_Node_Kind_Type :=
                     LAL.Ada_Node_Kind_Type'Value (Name);
               begin
                  Enabled_Kinds (Kind) := True;
               end;
            exception
               when Constraint_Error =>
                  Stop_With_Error ("invalid kind name: " & Name);
            end;
         end if;
      end Process_Name;

   begin
      for Cur in Start .. List'Last loop
         if List (Cur) = ',' then
            Process_Name (List (Start .. Cur - 1));
            Start := Cur + 1;
         elsif Cur = List'Last then
            Process_Name (List (Start .. Cur));
         end if;
      end loop;
   end Decode_Kinds;

   ----------------------------
   -- Is_Navigation_Disabled --
   ----------------------------

   function Is_Navigation_Disabled (N : LAL.Ada_Node) return Boolean is

      function Lowercase_Name (Id : LAL.Identifier) return String is
        (To_Lower (Langkit_Support.Text.Image (LAL.Text (Id.F_Tok))));

      function Has_Disable_Navigation
        (Aspects : LAL.Aspect_Spec) return Boolean;

      ----------------------------
      -- Has_Disable_Navigation --
      ----------------------------

      function Has_Disable_Navigation
        (Aspects : LAL.Aspect_Spec) return Boolean
      is
         use type LAL.Ada_Node_Kind_Type;
         use type LAL.Aspect_Spec;
      begin
         if Aspects = null then
            return False;
         end if;
         for Child of Aspects.F_Aspect_Assocs.Children loop
            declare
               Assoc : constant LAL.Aspect_Assoc := LAL.Aspect_Assoc (Child);
            begin
               if Assoc.F_Id.Kind = LAL.Ada_Identifier then
                  declare
                     Id : constant LAL.Identifier :=
                        LAL.Identifier (Assoc.F_Id);
                  begin
                     return Lowercase_Name (Id) = "disable_navigation";
                  end;
               end if;
            end;
         end loop;
         return False;
      end Has_Disable_Navigation;

   begin
      case N.Kind is
         when LAL.Ada_Base_Package_Decl =>
            return Has_Disable_Navigation
               (LAL.Base_Package_Decl (N).F_Aspects);
         when others =>
            return False;
      end case;
   end Is_Navigation_Disabled;


   current_compilation_Unit    : AdaM.compilation_Unit.view;
--     current_package_Declaration : AdaM.Declaration.of_package.view;


begin
   Ctx := LAL.Create;

   -- Add package Standard.
   --
   declare
      standard_Package : constant AdaM.a_Package.view := AdaM.a_Package.new_Package ("Standard");

   begin
      current_compilation_Unit := AdaM.compilation_Unit.new_compilation_Unit (Name => "Standard");
      Environ.add (current_compilation_Unit);
      Environ.standard_package_is (standard_Package);
      current_compilation_Unit.Entity_is (standard_Package.all'Access);

      add_Boolean:
      declare
         new_enum_Type : constant AdaM.a_Type.enumeration_type.view
           := AdaM.a_Type.enumeration_type.new_Type (Name => "Boolean");
      begin
         new_enum_Type.add_Literal ("False");
         new_enum_Type.add_Literal ("True");

         standard_Package.Children.append (new_enum_Type.all'Access);
      end add_Boolean;

      add_Integer:
      declare
         new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
           := AdaM.a_Type.signed_integer_type.new_Type (Name => "Integer");
      begin
         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_Integer;

      add_Natural:
      declare
         new_Subtype : constant AdaM.a_Type.a_subtype.view
           := AdaM.a_Type.a_subtype.new_Type (Name => "Natural");
      begin
         standard_Package.Children.append (new_Subtype.all'Access);
      end add_Natural;

      add_Positive:
      declare
         new_Subtype : constant AdaM.a_Type.a_subtype.view
           := AdaM.a_Type.a_subtype.new_Type (Name => "Positive");
      begin
         standard_Package.Children.append (new_Subtype.all'Access);
      end add_Positive;

   end;




   for I in 1 .. 1 loop -- CMD.Argument_Count loop
      declare
--           Arg  : constant String := CMD.Argument (I);
--           Unit : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, Arg);
         Unit : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, "standard.ads");
      begin
--           Put_Title ('#', Arg);
--           Process_File (Unit, Arg);
         Process_File (Unit, "standard.ads");
      end;
   end loop;

   LAL.Destroy (Ctx);
   Put_Line ("Done.");

exception
   when Fatal_Error =>
      CMD.Set_Exit_Status (CMD.Failure);
end Navigate;
