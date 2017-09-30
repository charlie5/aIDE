with
     AdaM.Environment,
     AdaM.Entity,
     AdaM.compilation_Unit,
     AdaM.Declaration.of_package,
     AdaM.Declaration.of_object,
     AdaM.a_Pragma,
     AdaM.a_Package,
     AdaM.a_Type.universal_type,
     AdaM.a_Type.enumeration_type,
     AdaM.a_Type.signed_integer_type,
     AdaM.a_Type.a_subtype,
     AdaM.a_Type.floating_point_type,
     AdaM.a_Type.array_type,
     AdaM.a_Type.ordinary_fixed_point_type,
     AdaM.subtype_indication,
     AdaM.Declaration.of_exception,
     AdaM.Declaration.of_exception,
     AdaM.Assist;

with Ada.Characters.Handling;
with ada.strings.fixed;
with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;

with Langkit_Support.Diagnostics;
with Langkit_Support.Text;
with Libadalang.Analysis;

with ada.Wide_Wide_Text_IO;
with ada.Characters.Conversions;
use Libadalang.Analysis;


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

                  when LAL.Ada_Anonymous_Type =>
                     log ("Ada_Anonymous_Type found");
                     lal.print (Child);

                     declare
                        Value : constant String := to_String (LAL.Anonymous_Type (Child).Text);
                     begin
                        log ("Anonymous type text : '" & Value & "'");
                        --                          new_Object.Initialiser_is (Value);
                        Depth := Depth + 1;

                        for i in 1 .. Child.child_Count
                        loop
                           declare
                              sub_Child : LAL.Ada_Node := Child.Child (i);
                           begin
                              if sub_Child = null
                              then
                                 log ("Null Node");
                              else
                                 case sub_Child.Kind
                                 is
                                 when LAL.Ada_Aggregate =>
                                    --                                      new_Object.is_Constant;
                                    log ("Aggregate found");
                                    Depth := Depth + 1;

                                    for j in 1 .. sub_Child.Child_Count
                                    loop
                                       declare
                                          sub_sub_Child : LAL.Ada_Node := sub_Child.Child (j);
                                       begin
                                          if sub_sub_Child = null
                                          then
                                             log ("Null Node");
                                          else
                                             case sub_sub_Child.Kind
                                             is
                                             when LAL.Ada_Aggregate =>
                                                --                                      new_Object.is_Constant;
                                                log ("Aggregate found");
                                             when others =>
                                                Put_Line (Indent & "1 Skip pre-processing of " & Short_Image (sub_sub_Child)
                                                          & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (sub_sub_Child.Kind));
                                             end case;
                                          end if;
                                       end;
                                    end loop;
                                    Depth := Depth - 1;

                                 when others =>
                                    Put_Line (Indent & "2 Skip pre-processing of " & Short_Image (sub_Child)
                                              & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (sub_Child.Kind));
                                 end case;
                              end if;
                           end;

                        end loop;
                     end;

                     Depth := Depth - 1;

                  when others =>
                     Put_Line (Indent & "3 Skip pre-processing of " & Short_Image (Child)
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
                     Put_Line (Indent & "4 Skip pre-processing of " & Short_Image (Child)
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
                     Put_Line (Indent & "5 Skip pre-processing of " & Short_Image (Child)
                               & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Child.Kind));
               end case;
            end if;
         end;
      end loop;

      Depth := Depth - 1;

      return new_Enumeration;
   end parse_Enumeration;




   procedure parse_subtype_Indication (Node           : in     LAL.Subtype_Indication;
                                       new_Indication :    out AdaM.subtype_Indication.item'Class)
   is
      use ada.Characters.Conversions;

      index_Type         : constant String               := to_String (Node.F_Name.Text);
      Constraint         : constant LAL.Range_Constraint := LAL.Range_Constraint (Node.Child (3));

   begin
      Depth := Depth + 1;

      log ("parse_subtype_Indication");

      -- Parse children.
      --
      new_Indication.main_Type_is (Environ.find (Identifier (index_Type)));

      if Constraint /= null
      then
         declare
            the_Range : constant LAL.Bin_Op           := LAL.Bin_Op (Constraint.Child (1));
            First     : constant String               := to_String (the_Range.Child (1).Text);
            Last      : constant String               := to_String (the_Range.Child (3).Text);
         begin
            new_Indication.First_is (First);
            new_Indication.Last_is  (Last);
         end;
      end if;

      Depth := Depth - 1;
   end parse_subtype_Indication;






   function parse_array_Type (Named : in String;
                              Node  : in LAL.Array_Type_Def) return AdaM.a_Type.array_type.view
   is
      use ada.Characters.Conversions;

      new_array_Type : constant AdaM.a_Type.array_type.view := AdaM.a_Type.array_type.new_Type (Named);

   begin
      Depth := Depth + 1;

--        log ("Name: '" & Name & "'");


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
                  when LAL.Ada_Constrained_Array_Indices =>
                     log ("parsing Ada_Constrained_Array_Indices");

                     new_array_Type.is_Constrained;

                     LAL.print (Child);

                     Put_Line (Indent & "<parse_array_Type> processing of " & Short_Image (Child)
                               & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Child.Kind));


                     log ("my CHILD COUNT: " & Integer'Image (Child.Child_Count));

                     declare
                        Indices            : constant LAL.Constrained_Array_Indices := LAL.Constrained_Array_Indices (Child);
                        node_List          : constant LAL.Ada_Node_List             := LAL.Ada_Node_List (Indices.Child (1));

                        subtype_Indication : LAL.Subtype_Indication        := LAL.Subtype_Indication (node_List.Child (1));
--                          index_Type         : String                        := to_String (subtype_Indication.F_Name.Text);
--                          Constraint         : LAL.Range_Constraint          := LAL.Range_Constraint (subtype_Indication.Child (3));
--                          the_Range          : LAL.Bin_Op                    := LAL.Bin_Op (Constraint.Child (1));
--                          First              : String                        := to_String (the_Range.Child (1).Text);
--                          Last               : String                        := to_String (the_Range.Child (3).Text);

                     begin
                        Put_Line (Indent & "<parse_array_Type> processing of " & Short_Image (Indices)
                                  & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Indices.Kind));

                        parse_subtype_Indication (subtype_Indication, new_array_Type.index_Indication.all);

--                          log ("subtype_Indication CHILD COUNT: " & Integer'Image (subtype_Indication.Child_Count));
--                          log ("index_Type NAME: " & index_Type);
--                          new_array_Type.index_Type_is (Environ.find (Identifier (index_Type)));
--
--                          log ("FIRST = '" & First & "'");
--                          log ("LAST  = '" & Last  & "'");
--                          new_array_Type.First_is (First);
--                          new_array_Type.Last_is  (Last);

--                          for i in 1 .. subtype_Indication.child_Count
--                          loop
--                             declare
--                                Literal : LAL.Enum_Literal_Decl := LAL.Enum_Literal_Decl (subtype_Indication.Child (i));
--                                Name    : String                := to_String (Literal.P_Defining_Name.Text);
--
--                             begin
--                                log ("'" & Name & "'");
--  --                                new_Enumeration.add_Literal (Name);
--                             end;
--                          end loop;
                     end;


                  when LAL.Ada_Component_Def =>
                     log ("");
                     log ("parsing Ada_Component_Def");

                     LAL.print (Child);

                     declare
                        Component : LAL.Component_Def := LAL.Component_Def (Child);
                     begin
                        if Component = null
                        then
                           log ("NULLLLLLLLLLLLLLLLLLLLLLLLL");
                        end if;

                        if Component.F_Has_Aliased
                        then
                           new_array_Type.Element_is_aliased;
                        end if;

                        parse_subtype_Indication (LAL.subtype_Indication (Component.Child (2)),
                                                  new_array_Type.element_Indication.all);
                     end;

--                       new_array_Type.element_Indication.main_Type_is (Environ.find ("Standard.Integer"));


                     -- Others
                     --
                  when others =>
                     Put_Line (Indent & "<parse_array_Type> Skip pre-processing of " & Short_Image (Child)
                               & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Child.Kind));
               end case;
            end if;
         end;
      end loop;

      Depth := Depth - 1;

      return new_array_Type; -- new_Enumeration.all'Access;
   end parse_array_Type;




   function parse_Type (Node : in LAL.Type_Decl) return AdaM.a_Type.view
   is
      use ada.Characters.Conversions;

      Name            : constant String                            := to_String (Node.P_Defining_Name.Text);
      new_Enumeration : constant AdaM.a_Type.enumeration_type.view := AdaM.a_Type.enumeration_type.new_Type (Name);

--  --        Ids : LAL.Identifier_List := Node.F_Ids;
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
                  when LAL.Ada_Array_Type_Def =>
                     log ("parsing Ada_Array_Type_Def");

                     return AdaM.a_Type.view (parse_array_Type (named => Name, node => LAL.Array_Type_Def (Child)));

--                       declare
--                          Def : LAL.Array_Type_Def := LAL.Array_Type_Def (Child);
--                       begin
--                          for i in 1 .. Def.child_Count
--                          loop
--                             declare
--                                Literal : LAL.Enum_Literal_Decl := LAL.Enum_Literal_Decl (Def.Child (i));
--                                Name    : String                := to_String (Literal.P_Defining_Name.Text);
--
--                             begin
--                                log ("'" & Name & "'");
--  --                                new_Enumeration.add_Literal (Name);
--                             end;
--                          end loop;
--                       end;

                     -- Others
                     --
                  when others =>
                     Put_Line (Indent & "<parse_type> Skip pre-processing of " & Short_Image (Child)
                               & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Child.Kind));
               end case;
            end if;
         end;
      end loop;

      Depth := Depth - 1;

      return new_Enumeration.all'Access;
   end parse_Type;




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

         when LAL.Ada_Type_Decl =>
            log ("Processing an Ada_Type_Decl");

            new_Entity := parse_Type (LAL.Type_Decl (Node)).all'Access;
--              skip_Children := True;

         -- Others
         --
         when others =>
            Put_Line (Indent & "Skip pre-processing of " & Short_Image (Node)
                     & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Node.Kind));
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

--     for Each of ada_Family
--     loop
--        declare
--           Prefix : constant String   := "/usr/lib/gcc/x86_64-pc-linux-gnu/7.2.0/adainclude/";
--           Arg    : constant String   := Each.all;
--           Unit   : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, Prefix & Arg);
--           --           Unit : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, "standard.ads");
--        begin
--           process_File (Unit, Prefix & Arg);
--        end;
--     end loop;

   declare
      Prefix : constant String   := "/eden/forge/applet/tool/aIDE/applet/aide/test/";
      Arg    : constant String   := "test_package.ads";
      Unit   : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, Prefix & Arg);
   begin
      process_File (Unit, Prefix & Arg);
   end;

   LAL.Destroy (Ctx);
   put_Line ("Done.");
   new_Line;

   return Environ;
end AdaM.Navigate;