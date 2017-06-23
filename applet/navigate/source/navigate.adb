with
     AdaM.Environment,
     AdaM.a_Type.enumeration_type,
     AdaM.a_Type.signed_integer_type,
     AdaM.a_Type.a_subtype,
     AdaM.a_Type.floating_point_type,
     AdaM.a_Type.unconstrained_array_type,
     AdaM.a_Type.ordinary_fixed_point_type,
     AdaM.Declaration.of_exception;

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

function Navigate return AdaM.Environment.item
is
   Environ : AdaM.Environment.item;

   type String_view is access String;
   type Strings is array (Positive range <>) of String_view;

   ada_Family : Strings := (1 => new String' ("ada.ads"));

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
     (             Enabled_Kinds (N.Kind)
      and then not Is_Navigation_Disabled (N));

   procedure Process_File (Unit : LAL.Analysis_Unit; Filename : String);

   procedure Print_Navigation (Part_Name  : String;
                               Orig, Dest : access LAL.Ada_Node_Type'Class);


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
         It            : LAL.Local_Find_Iterator := LAL.Root (Unit).Find (Node_Filter'Access);
         At_Least_Once : Boolean                 := False;
         Node          : LAL.Ada_Node;
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

   add_package_Standard:
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

      add_short_short_Integer:
      declare
         new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
           := AdaM.a_Type.signed_integer_type.new_Type (Name => "short_short_Integer");
      begin
         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_short_short_Integer;

      add_short_Integer:
      declare
         new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
           := AdaM.a_Type.signed_integer_type.new_Type (Name => "short_Integer");
      begin
         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_short_Integer;

      add_long_Integer:
      declare
         new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
           := AdaM.a_Type.signed_integer_type.new_Type (Name => "long_Integer");
      begin
         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_long_Integer;

      add_long_long_Integer:
      declare
         new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
           := AdaM.a_Type.signed_integer_type.new_Type (Name => "long_long_Integer");
      begin
         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_long_long_Integer;

      add_short_Float:
      declare
         new_float_Type : constant AdaM.a_Type.floating_point_type.view
           := AdaM.a_Type.floating_point_type.new_Type (Name => "short_Float");
      begin
         standard_Package.Children.append (new_float_Type.all'Access);
      end add_short_Float;

      add_Float:
      declare
         new_float_Type : constant AdaM.a_Type.floating_point_type.view
           := AdaM.a_Type.floating_point_type.new_Type (Name => "Float");
      begin
         standard_Package.Children.append (new_float_Type.all'Access);
      end add_Float;

      add_long_Float:
      declare
         new_float_Type : constant AdaM.a_Type.floating_point_type.view
           := AdaM.a_Type.floating_point_type.new_Type (Name => "long_Float");
      begin
         standard_Package.Children.append (new_float_Type.all'Access);
      end add_long_Float;

      add_long_long_Float:
      declare
         new_float_Type : constant AdaM.a_Type.floating_point_type.view
           := AdaM.a_Type.floating_point_type.new_Type (Name => "long_long_Float");
      begin
         standard_Package.Children.append (new_float_Type.all'Access);
      end add_long_long_Float;

      add_Character:
      declare
         new_enum_Type : constant AdaM.a_Type.enumeration_type.view
           := AdaM.a_Type.enumeration_type.new_Type (Name => "Character");
      begin
         standard_Package.Children.append (new_enum_Type.all'Access);
      end add_Character;

      add_wide_Character:
      declare
         new_enum_Type : constant AdaM.a_Type.enumeration_type.view
           := AdaM.a_Type.enumeration_type.new_Type (Name => "wide_Character");
      begin
         standard_Package.Children.append (new_enum_Type.all'Access);
      end add_wide_Character;

      add_wide_wide_Character:
      declare
         new_enum_Type : constant AdaM.a_Type.enumeration_type.view
           := AdaM.a_Type.enumeration_type.new_Type (Name => "wide_wide_Character");
      begin
         standard_Package.Children.append (new_enum_Type.all'Access);
      end add_wide_wide_Character;

      add_String:
      declare
         new_array_Type : constant AdaM.a_Type.unconstrained_array_type.view
           := AdaM.a_Type.unconstrained_array_type.new_Type (Name => "String");
      begin
         standard_Package.Children.append (new_array_Type.all'Access);
      end add_String;

      add_wide_String:
      declare
         new_array_Type : constant AdaM.a_Type.unconstrained_array_type.view
           := AdaM.a_Type.unconstrained_array_type.new_Type (Name => "wide_String");
      begin
         standard_Package.Children.append (new_array_Type.all'Access);
      end add_wide_String;

      add_wide_wide_String:
      declare
         new_array_Type : constant AdaM.a_Type.unconstrained_array_type.view
           := AdaM.a_Type.unconstrained_array_type.new_Type (Name => "wide_wide_String");
      begin
         standard_Package.Children.append (new_array_Type.all'Access);
      end add_wide_wide_String;

      add_Duration:
      declare
         new_ordinary_fixed_Type : constant AdaM.a_Type.ordinary_fixed_point_type.view
           := AdaM.a_Type.ordinary_fixed_point_type.new_Type (Name => "Duration");
      begin
         standard_Package.Children.append (new_ordinary_fixed_Type.all'Access);
      end add_Duration;

      add_constraint_Error:
      declare
         new_Exception : AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("constraint_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_constraint_Error;

      add_program_Error:
      declare
         new_Exception : AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("program_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_program_Error;

      add_storage_Error:
      declare
         new_Exception : AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("storage_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_storage_Error;

      add_tasking_Error:
      declare
         new_Exception : AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("tasking_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_tasking_Error;

      add_numeric_Error:   -- TODO: Make this a proper exception renaming as per 'standard.ads'.
      declare
         new_Exception : AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("numeric_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_numeric_Error;

   end add_package_Standard;



   for Each of ada_Family
   loop

--     for I in 1 .. 1 loop -- CMD.Argument_Count loop
      declare
         Prefix : constant String := "/usr/lib/gcc/x86_64-pc-linux-gnu/7.1.1/adainclude/";
         Arg    : constant String := Each.all;
         Unit   : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, Prefix & Arg);
--           Unit : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, "standard.ads");
      begin
         Put_Title ('#', Arg);
         Process_File (Unit, Prefix & Arg);
--           Process_File (Unit, "standard.ads");
      end;
   end loop;

   LAL.Destroy (Ctx);
   Put_Line ("Done.");


   return Environ;
end Navigate;
