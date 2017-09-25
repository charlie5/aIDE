with
     AdaM.Environment,
     AdaM.Entity,
     AdaM.compilation_Unit,
     AdaM.Declaration.of_package,
     AdaM.Declaration.of_object,
     AdaM.a_Pragma,
     AdaM.a_Package,
     AdaM.a_Type.enumeration_type,
     AdaM.a_Type.signed_integer_type,
     AdaM.a_Type.a_subtype,
     AdaM.a_Type.floating_point_type,
     AdaM.a_Type.array_type,
     AdaM.a_Type.ordinary_fixed_point_type,
     AdaM.Declaration.of_exception,
     AdaM.Assist;

with Ada.Characters.Handling;
with ada.strings.fixed;
with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;

with Langkit_Support.Diagnostics;
with Langkit_Support.Text;
with Libadalang.Analysis;

with Put_Title;
with ada.Wide_Wide_Text_IO;
with ada.Characters.Conversions;


function AdaM.Navigate return AdaM.Environment.item
is
   Environ : AdaM.Environment.item;

   current_compilation_Unit : AdaM.compilation_Unit.view;
   current_Package          : AdaM.Declaration.of_package.view;

   current_Parent : AdaM.Entity.view;


   type String_view is access String;
   type Strings is array (Positive range <>) of String_view;

   ada_Family : Strings := (new String' ("ada.ads"),
                            new String' ("a-string.ads"),
                            new String' ("a-calend.ads"));


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

   At_Least_Once : Boolean := False;



   Depth : Natural := 0;

   function Indent return String
   is
      use Ada.Strings.fixed;
   begin
      return Depth * "   ";
   end Indent;

   procedure log (Message : in String)
   is
   begin
      put_Line (Indent & Message);
   end log;



   procedure process (Node : in LAL.Ada_Node);



   function parse_object_Declaration (Node : in LAL.Object_Decl) return AdaM.Declaration.of_object.view
   is
      use ada.Characters.Conversions;
      Name        : constant String                          := to_String (Node.P_Defining_Name.Text);
      new_Object  : constant AdaM.Declaration.of_object.view := AdaM.Declaration.of_object.new_Declaration (Name);
   begin
      Depth := Depth + 1;
      log ("Object Name: '" & Name & "'");

      -- Parse children.
      --
      put_Line (Indent & "Child Count: " & Integer'Image (Node.Child_Count));

      for i in 1 .. Node.child_Count
      loop
         declare
            use type LAL.Ada_Node;
            Child : LAL.Ada_Node := Node.Child (i);
         begin
            if Child = null
            then
               log ("Null Node");
            else
               case Child.Kind
               is
                  when LAL.Ada_Constant_Present =>
                     new_Object.is_Constant;
                     log ("Object is constant");

                  when LAL.Ada_Subtype_Indication =>
                     log ("Ada_Subtype_Indication found");

                     declare
                        Name : constant AdaM.Identifier := AdaM.Identifier (to_String (LAL.Subtype_Indication (Child).F_Name.Text));
                     begin
                        log ("Subtype Name : '" & String (Name) & "'");
                        new_Object.Type_is (Environ.find (Name));
                     end;

                  when LAL.Ada_Char_Literal =>
                     log ("Ada_Char_Literal found");

                     declare
                        Value : constant String := to_String (LAL.Char_Literal (Child).Text);
                     begin
                        log ("Literal value : '" & Value & "'");
                        new_Object.Initialiser_is (Value);
                     end;

                  when others =>
                     Put_Line (Indent & "Skip pre-processing of " & Short_Image (Child)
                               & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Child.Kind));
               end case;
            end if;
         end;
      end loop;

      Depth := Depth - 1;

      return new_Object;
   end parse_object_Declaration;



   function parse_Pragma (Node : in LAL.Pragma_Node) return AdaM.a_Pragma.view
   is
      use ada.Characters.Conversions;

      Name        : constant String             := to_String (Node.F_Id.Text);
      new_Pragma  : constant AdaM.a_Pragma.view := AdaM.a_Pragma.new_Pragma (Name);

   begin
      Depth := Depth + 1;
      log ("Object Name: '" & Name & "'");


      -- Parse children.
      --
      put_Line (Indent & "Child Count: " & Integer'Image (Node.Child_Count));

      for i in 1 .. Node.child_Count
      loop
         declare
            use type LAL.Ada_Node;
            Child : LAL.Ada_Node := Node.Child (i);
         begin
            if Child = null
            then
               log ("Null Node");

            else
               case Child.Kind
               is
                  when LAL.Ada_Base_Assoc_List =>
--                       log ("ADA_BASE_ASSOC_LIST");

                     declare
                        List : LAL.Base_Assoc_List := LAL.Base_Assoc_List (Child);
                     begin
                        if not List.Is_Empty_List
                        then
--                             List.Print;
--                             put_Line ("LIST CHILD COUNT: " & Natural'Image (List.Child_Count));
                           for i in 1 .. List.Child_Count
                           loop
                              declare
                                 Pragma_Arg : LAL.Pragma_Argument_Assoc := LAL.Pragma_Argument_Assoc (List.Child (i));
                                 Arg        : String := to_String (Pragma_Arg.F_Expr.Text);
                              begin
--                                Pragma_Arg.Print;
--                                put_Line ("'" & Arg & "'");

                                 new_Pragma.add_Argument (Arg);
                              end;
                           end loop;
                        end if;
                     end;

                     -- Others
                     --
                  when others =>
                     Put_Line (Indent & "Skip pre-processing of " & Short_Image (Child)
                               & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Child.Kind));
               end case;
            end if;
         end;
      end loop;

      Depth := Depth - 1;

      return new_Pragma;
   end parse_Pragma;




   procedure parse_Exception (Node : in LAL.Exception_Decl)
   is
      use ada.Characters.Conversions;

      Ids : LAL.Identifier_List := Node.F_Ids;
   begin
      Depth := Depth + 1;

      -- Parse children.
      --
      put_Line (Indent & "Ids Child Count: " & Integer'Image (Ids.Child_Count));

      for i in 1 .. Ids.child_Count
      loop
         declare
            use type LAL.Ada_Node;
            Child         : LAL.Identifier := LAL.Identifier (Ids.Child (i));
            Name          : String         := LAL.Text (Child.F_Tok);
            new_Exception : AdaM.Declaration.of_exception.view := AdaM.Declaration.of_exception.new_Declaration (Name);
         begin
            current_Parent.Children.append (new_Exception.all'Access);
            new_Exception.parent_Entity_is (current_Parent);
         end;
      end loop;

      Depth := Depth - 1;
   end parse_Exception;



   function parse_Enumeration (Node : in LAL.Enum_Type_Decl) return AdaM.a_Type.enumeration_type.view
   is
      use ada.Characters.Conversions;

      Name            : constant String                            := to_String (Node.P_Defining_Name.Text);
      new_Enumeration : constant AdaM.a_Type.enumeration_type.view := AdaM.a_Type.enumeration_type.new_Type (Name);

--        Ids : LAL.Identifier_List := Node.F_Ids;
   begin
      Depth := Depth + 1;

      log ("Name: '" & Name & "'");

      -- Parse children.
      --
      put_Line (Indent & "Child Count: " & Integer'Image (Node.Child_Count));

      for i in 1 .. Node.child_Count
      loop
         declare
            use type LAL.Ada_Node;
            Child : LAL.Ada_Node := Node.Child (i);
         begin
            if Child = null
            then
               log ("Null Node");

            else
               case Child.Kind
               is
                  when LAL.Ada_Enum_Literal_Decl_List =>
                     log ("parsing Ada_Enum_Literal_Decl_List");

                     declare
                        List : LAL.Enum_Literal_Decl_List := LAL.Enum_Literal_Decl_List (Child);
                     begin
                        for i in 1 .. List.child_Count
                        loop
                           declare
                              Literal : LAL.Enum_Literal_Decl := LAL.Enum_Literal_Decl (List.Child (i));
                              Name    : String                := to_String (Literal.P_Defining_Name.Text);

                           begin
                              log ("'" & Name & "'");
                              new_Enumeration.add_Literal (Name);
                           end;
                        end loop;
                     end;

                     -- Others
                     --
                  when others =>
                     Put_Line (Indent & "Skip pre-processing of " & Short_Image (Child)
                               & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Child.Kind));
               end case;
            end if;
         end;
      end loop;

      Depth := Depth - 1;

      return new_Enumeration;
   end parse_Enumeration;




   function parse_Package (Node : in LAL.Package_Decl) return AdaM.Declaration.of_package.view
   is
      use AdaM,
          AdaM.Assist,
          AdaM.Environment,
          ada.Characters.Conversions;

      use type AdaM.Declaration.of_package.view;

      Name        : constant AdaM.Identifier := AdaM.Identifier (to_String (Node.P_Defining_Name.Text));

--        new_Package : constant AdaM.Declaration.of_package.view := AdaM.Declaration.of_package.new_Package (Name);
      new_Package : AdaM.Declaration.of_package.view; -- := AdaM.Declaration.of_package.new_Package (Name);

      parent_Name : constant AdaM.Identifier    := Adam.Assist.parent_Name (Name);   -- strip_Tail_of (Name);
      Parent      :          AdaM.a_Package.view; -- := Environ.fetch (parent_Name);

   begin
      if current_Package = null
      then
         Parent := Environ.fetch (parent_Name);
      else
         Parent := current_Package;
      end if;

      new_Package := AdaM.Declaration.of_package.new_Package (simple_Name (Name));

      log ("Package Name: '" & (+new_Package.Name) & "'     Parent Name: '" & (+Parent.Name) & "'");

      Parent.add_Child (new_Package);
      new_Package.Parent_is (Parent);

      current_compilation_Unit.Entity_is (new_Package.all'Access);
      current_Package := new_Package;
      log ("Setting current package to " & (+current_Package.Name));


      -- Parse children.
      --
--        put_Line (Indent & "Child Count: " & Integer'Image (Node.Child_Count));
--
--        for i in 1 .. Node.child_Count
--        loop
--           process (Node.Child (i));
--        end loop;
--
--        current_Package := current_Package.Parent;

      return new_Package;
   end parse_Package;






   procedure process (Node : in LAL.Ada_Node)
   is
      use AdaM;
      use type AdaM.Entity.view,
               LAL.Ada_Node;

      new_Entity          : AdaM.Entity.view;
      Processed_Something : Boolean := True;
      skip_Children       : Boolean := False;

   begin
      if Node = null
      then
         Depth := Depth + 1;
         new_Line;
         log ("Null Node");
         Depth := Depth - 1;

         return;
      end if;

      Depth := Depth + 1;
      new_Line;


      -- Pre-op
      --
      case Node.Kind
      is
         --  Packages
         --
         when LAL.Ada_Base_Package_Decl =>
            log ("Processing an Ada_Base_Package_Decl");

            new_Entity := parse_Package (LAL.Package_Decl (Node)).all'Access;
--              skip_Children := True;

         when LAL.Ada_Package_Body =>
            Print_Navigation
              (Indent & "Decl", Node, LAL.Package_Body (Node).P_Decl_Part);

         when LAL.Ada_Generic_Package_Decl =>
            Print_Navigation
              (Indent & "Body", Node,
               LAL.Generic_Package_Decl (Node).P_Body_Part);

            --  Subprograms
            --
         when LAL.Ada_Subp_Decl =>
            Print_Navigation
              (Indent & "Body", Node, LAL.Subp_Decl (Node).P_Body_Part);

         when LAL.Ada_Subp_Body =>
            Print_Navigation
              (Indent & "Decl", Node, LAL.Subp_Body (Node).P_Decl_Part);

         when LAL.Ada_Generic_Subp_Decl =>
            Print_Navigation
              (Indent & "Body", Node,
               LAL.Generic_Subp_Decl (Node).P_Body_Part);

         when LAL.Ada_Pragma_Node =>
            log ("Processing an Ada_Pragma_Node");

            new_Entity := parse_Pragma (LAL.Pragma_Node (Node)).all'Access;
            skip_Children := True;

         when LAL.Ada_Object_Decl =>
            log ("Processing an Ada_Object_Decl");

            new_Entity := parse_object_Declaration (LAL.Object_Decl (Node)).all'Access;
            skip_Children := True;

--              declare
--                 use ada.Characters.Conversions;
--                 Name        : constant String             := to_String (LAL.Object_Decl (Node).P_Defining_Name.Text);
--                 new_Object  : constant AdaM.Declaration.of_object.view := AdaM.Declaration.of_object.new_Declaration (Name);
--              begin
--                 log ("Object Name: '" & Name & "'");
--                 new_Entity := new_Object.all'Access;
--              end;

         when LAL.Ada_Exception_Decl =>
            log ("Processing an Ada_Exception_Decl");

            parse_Exception (LAL.Exception_Decl (Node));
            skip_Children := True;

         when LAL.Ada_Enum_Type_Decl =>
            log ("Processing an Ada_Enum_Type_Decl");

            new_Entity := parse_Enumeration (LAL.Enum_Type_Decl (Node)).all'Access;
            skip_Children := True;

         -- Others
         --
         when others =>
            Put_Line (Indent & "Skip pre-processing of " & Short_Image (Node));
            Processed_Something := False;

      end case;

      At_Least_Once := At_Least_Once or else Processed_Something;


      if new_Entity /= null
      then
         if current_Parent = null
         then
            ada.Text_IO.put_Line (Indent & "Lowering current_Parent from null to " & (+new_Entity.Name));
            new_Entity.parent_Entity_is (null);
         else
            current_Parent.Children.append (new_Entity);

            ada.Text_IO.put_Line (Indent & "Lowering current_Parent from " & (+current_Parent.Name) &
                                    " to " & (+new_Entity.Name));
            new_Entity.parent_Entity_is (current_Parent);
         end if;

         current_Parent := new_Entity;
      end if;


      if not skip_Children
      then
         -- Recurse into children.
         --
         put_Line (Indent & "Child Count: " & Integer'Image (Node.Child_Count));

         for i in 1 .. Node.child_Count
         loop
            process (Node.Child (i));
         end loop;
      end if;


      -- Post-op.
      --
      if    new_Entity     /= null
        and current_Parent /= null
      then
         if current_Parent.parent_Entity /= null
         then
            ada.Text_IO.put_Line (Indent & "Raising current_Parent from " & (+current_Parent.Name) &
                                    " to " & (+current_Parent.parent_Entity.Name));
         else
            ada.Text_IO.put_Line (Indent & "Raising current_Parent from " & (+current_Parent.Name) &
                                    " to null");
         end if;

         current_Parent := current_Parent.parent_Entity;
      end if;

      case Node.Kind
      is
         when LAL.Ada_Base_Package_Decl =>
            log ("Setting current package to " & (+current_Package.Parent.Name));
            current_Package := current_Package.Parent;

         when others =>
            null;
      end case;


      Depth := Depth - 1;

   exception
      when LAL.Property_Error =>
         Put_Line (Indent & "Error when processing " & Short_Image (Node));
         At_Least_once := True;
   end process;



   procedure process_File (Unit     : in LAL.Analysis_Unit;
                           Filename : in String)
   is
   begin
      if LAL.Has_Diagnostics (Unit)
      then
         for D of LAL.Diagnostics (Unit)
         loop
            Put_Line ("error: " & Filename & ": "
                      & Langkit_Support.Diagnostics.To_Pretty_String (D));
         end loop;
         New_Line;

         return;
      end if;

      current_compilation_Unit := AdaM.compilation_Unit.new_compilation_Unit (Name => Filename);
      Environ.add (current_compilation_Unit);

      current_Package := null;

      LAL.Populate_Lexical_Env (Unit);

      declare
         Node : LAL.Ada_Node := LAL.Root (Unit);
      begin
         process (Node);

         if not At_Least_Once then
            Put_Line ("<no node to process>");
         end if;

         New_Line;
      end;
   end Process_File;




   procedure Print_Navigation (Part_Name  : String;
                               Orig, Dest : access LAL.Ada_Node_Type'Class)
   is
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

   function Is_Navigation_Disabled (N : LAL.Ada_Node) return Boolean
   is

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



begin
   Ctx := LAL.Create;

   Environ.add_package_Standard;

--     add_package_Standard:
--     declare
--        standard_Package : constant AdaM.a_Package.view := AdaM.a_Package.new_Package ("Standard");
--     begin
--        current_compilation_Unit := AdaM.compilation_Unit.new_compilation_Unit (Name => "Standard");
--        Environ.add (current_compilation_Unit);
--        Environ.standard_package_is (standard_Package);
--        current_compilation_Unit.Entity_is (standard_Package.all'Access);
--
--        add_pragma_Pure:
--        declare
--           new_Pragma : constant AdaM.a_Pragma.view
--             := AdaM.a_Pragma.new_Pragma (Name => "Pure");
--        begin
--           new_Pragma.add_Argument ("Standard");
--
--           standard_Package.Children.append (new_Pragma.all'Access);
--        end add_pragma_Pure;
--
--
--        add_Boolean:
--        declare
--           new_enum_Type : constant AdaM.a_Type.enumeration_type.view
--             := AdaM.a_Type.enumeration_type.new_Type (Name => "Boolean");
--        begin
--           new_enum_Type.add_Literal ("False");
--           new_enum_Type.add_Literal ("True");
--
--           standard_Package.Children.append (new_enum_Type.all'Access);
--        end add_Boolean;
--
--        add_Integer:
--        declare
--           new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
--             := AdaM.a_Type.signed_integer_type.new_Type (Name => "Integer");
--        begin
--           new_integer_Type.First_is (Long_Long_Integer (Integer'First));
--           new_integer_Type.Last_is  (Long_Long_Integer (Integer'Last));
--
--           standard_Package.Children.append (new_integer_Type.all'Access);
--        end add_Integer;
--
--        add_Natural:
--        declare
--           new_Subtype : constant AdaM.a_Type.a_subtype.view
--             := AdaM.a_Type.a_subtype.new_Type (Name => "Natural");
--        begin
--           new_Subtype.main_Type_is (Environ.find ("Integer"));
--           new_Subtype.First_is ("0");
--           new_Subtype.Last_is  ("Integer'Last");
--
--           standard_Package.Children.append (new_Subtype.all'Access);
--        end add_Natural;
--
--        add_Positive:
--        declare
--           new_Subtype : constant AdaM.a_Type.a_subtype.view
--             := AdaM.a_Type.a_subtype.new_Type (Name => "Positive");
--        begin
--           new_Subtype.main_Type_is (Environ.find ("Integer"));
--           new_Subtype.First_is ("1");
--           new_Subtype.Last_is  ("Integer'Last");
--
--           standard_Package.Children.append (new_Subtype.all'Access);
--        end add_Positive;
--
--        add_short_short_Integer:
--        declare
--           new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
--             := AdaM.a_Type.signed_integer_type.new_Type (Name => "Short_Short_Integer");
--        begin
--           new_integer_Type.First_is (Long_Long_Integer (Short_Short_Integer'First));
--           new_integer_Type.Last_is  (Long_Long_Integer (Short_Short_Integer'Last));
--
--           standard_Package.Children.append (new_integer_Type.all'Access);
--        end add_short_short_Integer;
--
--        add_short_Integer:
--        declare
--           new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
--             := AdaM.a_Type.signed_integer_type.new_Type (Name => "Short_Integer");
--        begin
--           new_integer_Type.First_is (Long_Long_Integer (short_Integer'First));
--           new_integer_Type.Last_is  (Long_Long_Integer (short_Integer'Last));
--
--           standard_Package.Children.append (new_integer_Type.all'Access);
--        end add_short_Integer;
--
--        add_long_Integer:
--        declare
--           new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
--             := AdaM.a_Type.signed_integer_type.new_Type (Name => "Long_Integer");
--        begin
--           new_integer_Type.First_is (Long_Long_Integer (long_Integer'First));
--           new_integer_Type.Last_is  (Long_Long_Integer (long_Integer'Last));
--
--           standard_Package.Children.append (new_integer_Type.all'Access);
--        end add_long_Integer;
--
--        add_long_long_Integer:
--        declare
--           new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
--             := AdaM.a_Type.signed_integer_type.new_Type (Name => "Long_Long_Integer");
--        begin
--           new_integer_Type.First_is (Long_Long_Integer'First);
--           new_integer_Type.Last_is  (Long_Long_Integer'Last);
--
--           standard_Package.Children.append (new_integer_Type.all'Access);
--        end add_long_long_Integer;
--
--
--        add_short_Float:
--        declare
--           new_float_Type : constant AdaM.a_Type.floating_point_type.view
--             := AdaM.a_Type.floating_point_type.new_Type (Name => "Short_Float");
--        begin
--           new_float_Type.Digits_are (6);
--           new_float_Type.First_is   (long_long_Float (Short_Float'First));
--           new_float_Type.Last_is    (long_long_Float (Short_Float'Last));
--
--           standard_Package.Children.append (new_float_Type.all'Access);
--        end add_short_Float;
--
--        add_Float:
--        declare
--           new_float_Type : constant AdaM.a_Type.floating_point_type.view
--             := AdaM.a_Type.floating_point_type.new_Type (Name => "Float");
--        begin
--           new_float_Type.Digits_are (6);
--           new_float_Type.First_is   (long_long_Float (Float'First));
--           new_float_Type.Last_is    (long_long_Float (Float'Last));
--
--           standard_Package.Children.append (new_float_Type.all'Access);
--        end add_Float;
--
--        add_long_Float:
--        declare
--           new_float_Type : constant AdaM.a_Type.floating_point_type.view
--             := AdaM.a_Type.floating_point_type.new_Type (Name => "Long_Float");
--        begin
--           new_float_Type.Digits_are (15);
--           new_float_Type.First_is   (long_long_Float (long_Float'First));
--           new_float_Type.Last_is    (long_long_Float (long_Float'Last));
--
--           standard_Package.Children.append (new_float_Type.all'Access);
--        end add_long_Float;
--
--        add_long_long_Float:
--        declare
--           new_float_Type : constant AdaM.a_Type.floating_point_type.view
--             := AdaM.a_Type.floating_point_type.new_Type (Name => "Long_Long_Float");
--        begin
--           new_float_Type.Digits_are (18);
--           new_float_Type.First_is   (long_long_Float'First);
--           new_float_Type.Last_is    (long_long_Float'Last);
--
--           standard_Package.Children.append (new_float_Type.all'Access);
--        end add_long_long_Float;
--
--
--        add_Character:
--        declare
--           new_enum_Type : constant AdaM.a_Type.enumeration_type.view
--             := AdaM.a_Type.enumeration_type.new_Type (Name => "Character");
--        begin
--           standard_Package.Children.append (new_enum_Type.all'Access);
--        end add_Character;
--
--        add_wide_Character:
--        declare
--           new_enum_Type : constant AdaM.a_Type.enumeration_type.view
--             := AdaM.a_Type.enumeration_type.new_Type (Name => "Wide_Character");
--        begin
--           standard_Package.Children.append (new_enum_Type.all'Access);
--        end add_wide_Character;
--
--        add_wide_wide_Character:
--        declare
--           new_enum_Type : constant AdaM.a_Type.enumeration_type.view
--             := AdaM.a_Type.enumeration_type.new_Type (Name => "Wide_Wide_Character");
--        begin
--           standard_Package.Children.append (new_enum_Type.all'Access);
--        end add_wide_wide_Character;
--
--        add_String:
--        declare
--           new_array_Type : constant AdaM.a_Type.array_type.view
--             := AdaM.a_Type.array_type.new_Type (Name => "String");
--
--           new_Pragma     : constant AdaM.a_Pragma.view
--             := AdaM.a_Pragma.new_Pragma (Name => "Pack");
--        begin
--           new_array_Type.  index_Type_is (Environ.find ("Standard.Positive"));
--           new_array_Type.element_Type_is (Environ.find ("Standard.Character"));
--           new_array_Type.is_Constrained  (Now => False);
--
--           new_Pragma.add_Argument ("String");
--
--           standard_Package.Children.append (new_array_Type.all'Access);
--           standard_Package.Children.append (new_Pragma.all'Access);
--        end add_String;
--
--        add_wide_String:
--        declare
--           new_array_Type : constant AdaM.a_Type.array_type.view
--             := AdaM.a_Type.array_type.new_Type (Name => "Wide_String");
--
--           new_Pragma     : constant AdaM.a_Pragma.view
--             := AdaM.a_Pragma.new_Pragma (Name => "Pack");
--        begin
--           new_array_Type.  index_Type_is (Environ.find ("Standard.Positive"));
--           new_array_Type.element_Type_is (Environ.find ("Standard.Wide_Character"));
--           new_array_Type.is_Constrained  (Now => False);
--
--           new_Pragma.add_Argument ("Wide_String");
--
--           standard_Package.Children.append (new_array_Type.all'Access);
--           standard_Package.Children.append (new_Pragma.all'Access);
--        end add_wide_String;
--
--        add_wide_wide_String:
--        declare
--           new_array_Type : constant AdaM.a_Type.array_type.view
--             := AdaM.a_Type.array_type.new_Type (Name => "Wide_Wide_String");
--
--           new_Pragma     : constant AdaM.a_Pragma.view
--             := AdaM.a_Pragma.new_Pragma (Name => "Pack");
--        begin
--           new_array_Type.  index_Type_is (Environ.find ("Standard.Positive"));
--           new_array_Type.element_Type_is (Environ.find ("Standard.Wide_Wide_Character"));
--           new_array_Type.is_Constrained  (Now => False);
--
--           standard_Package.Children.append (new_array_Type.all'Access);
--           standard_Package.Children.append (new_Pragma.all'Access);
--
--           new_Pragma.add_Argument ("Wide_Wide_String");
--        end add_wide_wide_String;
--
--        add_Duration:
--        declare
--           use Ada.Strings,
--               Ada.Strings.fixed;
--
--           new_ordinary_fixed_Type : constant AdaM.a_Type.ordinary_fixed_point_type.view
--             := AdaM.a_Type.ordinary_fixed_point_type.new_Type (Name => "Duration");
--        begin
--           new_ordinary_fixed_Type.Delta_is (Trim (Duration'Image (Duration'Delta), Left));
--           new_ordinary_fixed_Type.First_is ("-((2 ** 63)     * 0.000000001)");
--           new_ordinary_fixed_Type.Last_is  ("+((2 ** 63 - 1) * 0.000000001)");
--
--           standard_Package.Children.append (new_ordinary_fixed_Type.all'Access);
--        end add_Duration;
--
--        add_constraint_Error:
--        declare
--           new_Exception : AdaM.Declaration.of_exception.view
--             := Adam.Declaration.of_exception.new_Declaration ("Constraint_Error");
--        begin
--           standard_Package.Children.append (new_Exception.all'Access);
--        end add_constraint_Error;
--
--        add_program_Error:
--        declare
--           new_Exception : AdaM.Declaration.of_exception.view
--             := Adam.Declaration.of_exception.new_Declaration ("Program_Error");
--        begin
--           standard_Package.Children.append (new_Exception.all'Access);
--        end add_program_Error;
--
--        add_storage_Error:
--        declare
--           new_Exception : AdaM.Declaration.of_exception.view
--             := Adam.Declaration.of_exception.new_Declaration ("Storage_Error");
--        begin
--           standard_Package.Children.append (new_Exception.all'Access);
--        end add_storage_Error;
--
--        add_tasking_Error:
--        declare
--           new_Exception : AdaM.Declaration.of_exception.view
--             := Adam.Declaration.of_exception.new_Declaration ("Tasking_Error");
--        begin
--           standard_Package.Children.append (new_Exception.all'Access);
--        end add_tasking_Error;
--
--        add_numeric_Error:   -- TODO: Make this a proper exception renaming as per 'standard.ads'.
--        declare
--           new_Exception : AdaM.Declaration.of_exception.view
--             := Adam.Declaration.of_exception.new_Declaration ("Numeric_Error");
--        begin
--           standard_Package.Children.append (new_Exception.all'Access);
--        end add_numeric_Error;
--
--     end add_package_Standard;


   for Each of ada_Family
   loop

      --     for I in 1 .. 1 loop -- CMD.Argument_Count loop
      declare
         Prefix : constant String   := "/usr/lib/gcc/x86_64-pc-linux-gnu/7.2.0/adainclude/";
         Arg    : constant String   := Each.all;
         Unit   : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, Prefix & Arg);
         --           Unit : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, "standard.ads");
      begin
         Put_Title ('#', Arg);
         Process_File (Unit, Prefix & Arg);
         --           Process_File (Unit, "standard.ads");
      end;
   end loop;

   LAL.Destroy (Ctx);
   put_Line ("Done.");
   new_Line;


   return Environ;
end AdaM.Navigate;
