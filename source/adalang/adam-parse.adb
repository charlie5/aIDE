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
     AdaM.a_Type.record_type,
     AdaM.record_Component,
     AdaM.a_Type.ordinary_fixed_point_type,
     AdaM.a_Type.decimal_fixed_point_type,
     AdaM.a_Type.private_type,
     AdaM.a_Type.derived_type,
     AdaM.a_Type.access_type,

     AdaM.subtype_Indication,
     AdaM.Declaration.of_exception,
     AdaM.Assist;

with Ada.Characters.Handling;
with ada.strings.fixed;
with Ada.Text_IO; use Ada.Text_IO;

with Langkit_Support.Diagnostics;
with Langkit_Support.Text;
with Libadalang.Analysis;

with Ada.Characters.conversions;
use Libadalang.Analysis;


procedure AdaM.parse (File : in     String;
                      Into : in out AdaM.Environment.item)
is
   use Ada.Characters.conversions;


   pragma Unreferenced (File);
   Environ : AdaM.Environment.item renames Into;

   current_compilation_Unit : AdaM.compilation_Unit.view;
   current_Package          : AdaM.Declaration.of_package.view;

   type package_Section is (public_Part, private_Part);
   current_Section : package_Section;

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
   pragma Unreferenced (To_Lower);

   Fatal_Error   : exception;
   pragma Unreferenced (Fatal_Error);
   Ctx           : LAL.Analysis_Context := LAL.create;
   Enabled_Kinds : constant array (LAL.Ada_Node_Kind_type) of Boolean :=
     (others => True);

--     function Is_Navigation_Disabled (N : LAL.Ada_Node) return Boolean;

   function Node_Filter (N : LAL.Ada_Node) return Boolean
   is
     (             Enabled_Kinds (N.Kind));
   pragma Unreferenced (Node_Filter);
--        and then not Is_Navigation_Disabled (N));

   procedure Process_File (Unit : LAL.Analysis_Unit; Filename : String);

--     procedure Print_Navigation (Part_Name  : String;
--                                 Orig, Dest : access LAL.Ada_Node_Type'Class);

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


   ----------
   -- Process
   --

   procedure process (Node : in LAL.Ada_Node);



   procedure parse_Range (the_Range : in     LAL.Bin_Op;
                          First     :    out Text;
                          Last      :    out Text)
   is
   begin
      First := +to_String (the_Range.Child (1).Text);
      Last  := +to_String (the_Range.Child (3).Text);
   end parse_Range;



   procedure parse_subtype_Indication (Node           : in     LAL.Subtype_Indication;
                                       new_Indication :    out AdaM.subtype_Indication.item'Class)
   is

      index_Type : constant String               := to_String (Node.F_Name.Text);
      Constraint : constant LAL.Range_Constraint := LAL.Range_Constraint (Node.Child (3));

   begin
      Depth := Depth + 1;

      log ("parse_subtype_Indication");

      -- Parse children.
      --
      new_Indication.main_Type_is (Environ.find (Identifier (index_Type)));

      if Constraint /= null
      then
         if Constraint.Child (1).Kind = LAL.Ada_Bin_Op
         then
            new_Indication.is_Constrained (True);

            declare
               the_Range : constant LAL.Bin_Op := LAL.Bin_Op (Constraint.Child (1));
               First     :          Text;
               Last      :          Text;
            begin
               parse_Range (the_Range,  First, Last);

               new_Indication.First_is (+First);
               new_Indication.Last_is  (+Last);
            end;

         elsif Constraint.Child (1).Kind = LAL.Ada_Box_Expr
         then
            new_Indication.is_Constrained (False);
         else
            raise Program_Error with Constraint.Child (1).Kind_Name & " not yet supported";
         end if;

      else
         new_Indication.is_Constrained (True);
      end if;

      Depth := Depth - 1;
   end parse_subtype_Indication;




   function parse_array_Type (Named : in String;
                              Node  : in LAL.Array_Type_Def) return AdaM.a_Type.array_type.view
   is

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
            Child : constant LAL.Ada_Node := Node.Child (i);
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

                        subtype_Indication : constant LAL.Subtype_Indication        := LAL.Subtype_Indication (node_List.Child (1));
                     begin
                        Put_Line (  Indent & "<parse_array_Type> processing of " & Short_Image (Indices)
                                  & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Indices.Kind));

                        parse_subtype_Indication (subtype_Indication, new_array_Type.index_Indication.all);
--                          new_array_Type.index_Indication.is_Constrained;
                     end;


                  when LAL.Ada_Component_Def =>
                     log ("");
                     log ("parsing Ada_Component_Def");

--                       LAL.print (Child);

                     declare
                        Component : constant LAL.Component_Def := LAL.Component_Def (Child);
                     begin
                        if Component = null
                        then
                           log ("NULLLLLLLLLLLLLLLLLLLLLLLLL");
                        end if;

                        if Component.F_Has_Aliased
                        then
                           new_array_Type.Component_is_aliased;
                        end if;

                        parse_subtype_Indication (LAL.subtype_Indication (Component.Child (2)),
                                                  new_array_Type.component_Indication.all);
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




   function parse_anonymous_Type (Node : in LAL.Anonymous_Type) return AdaM.a_Type.view
   is
      node_Text   : constant String := to_String (Node.Text);
      Declaration : constant LAL.Anonymous_Type_Decl := LAL.Anonymous_Type_Decl (Node.Child (1));
      new_Type    :          AdaM.a_Type.view;
   begin
      log ("parse_anonymous_Type");
      log ("Anonymous type text : '" & node_Text & "'");

      Depth := Depth + 1;

      for i in 1 .. Declaration.child_Count
      loop
         declare
            Child : constant LAL.Ada_Node := Declaration.Child (i);
         begin
            if Child = null
            then
               log ("Null Node");
            else
               case Child.Kind
               is
                  when LAL.Ada_Aggregate =>   -- tbd: is this used ?
                     raise Program_Error with "is this used ?";
                     --                                      new_Object.is_Constant;
                     log ("Aggregate found");
                     Depth := Depth + 1;

                     for j in 1 .. Child.Child_Count
                     loop
                        declare
                           sub_Child : constant LAL.Ada_Node := Child.Child (j);
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

                                 when others =>
                                    Put_Line (Indent & "1 Skip pre-processing of " & Short_Image (sub_Child)
                                              & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (sub_Child.Kind));
                              end case;
                           end if;
                        end;
                     end loop;
                     Depth := Depth - 1;

                  when LAL.Ada_Array_Type_Def =>
                     log ("Ada_Array_Type_Def found");

                     declare
                        array_Def  : constant LAL.Array_Type_Def          := LAL.Array_Type_Def (Child);
                        array_Type : constant AdaM.a_Type.array_type.view := parse_array_Type ("", array_Def);
                     begin
                        new_Type := array_Type.all'Access;
                     end;

                  when others =>
                     Put_Line (Indent & "2 Skip pre-processing of " & Short_Image (Child)
                               & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Child.Kind));
               end case;
            end if;
         end;

      end loop;

      return new_Type;
   end parse_anonymous_Type;




   function parse_object_Declaration (Node : in LAL.Object_Decl) return AdaM.Declaration.of_object.view
   is
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
            Child : constant LAL.Ada_Node := Node.Child (i);
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
--                       lal.print (Child);

                     new_Object.Type_is (parse_anonymous_Type (LAL.Anonymous_Type (Child)));

--                       declare
--                          Value : constant String := to_String (LAL.Anonymous_Type (Child).Text);
--                       begin
--                          log ("Anonymous type text : '" & Value & "'");
--                          --                          new_Object.Initialiser_is (Value);
--                          Depth := Depth + 1;
--
--                          for i in 1 .. Child.child_Count
--                          loop
--                             declare
--                                sub_Child : LAL.Ada_Node := Child.Child (i);
--                             begin
--                                if sub_Child = null
--                                then
--                                   log ("Null Node");
--                                else
--                                   case sub_Child.Kind
--                                   is
--                                   when LAL.Ada_Aggregate =>
--                                      --                                      new_Object.is_Constant;
--                                      log ("Aggregate found");
--                                      Depth := Depth + 1;
--
--                                      for j in 1 .. sub_Child.Child_Count
--                                      loop
--                                         declare
--                                            sub_sub_Child : LAL.Ada_Node := sub_Child.Child (j);
--                                         begin
--                                            if sub_sub_Child = null
--                                            then
--                                               log ("Null Node");
--                                            else
--                                               case sub_sub_Child.Kind
--                                               is
--                                               when LAL.Ada_Aggregate =>
--                                                  --                                      new_Object.is_Constant;
--                                                  log ("Aggregate found");
--                                               when others =>
--                                                  Put_Line (Indent & "1 Skip pre-processing of " & Short_Image (sub_sub_Child)
--                                                            & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (sub_sub_Child.Kind));
--                                               end case;
--                                            end if;
--                                         end;
--                                      end loop;
--                                      Depth := Depth - 1;
--
--                                   when others =>
--                                      Put_Line (Indent & "2 Skip pre-processing of " & Short_Image (sub_Child)
--                                                & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (sub_Child.Kind));
--                                   end case;
--                                end if;
--                             end;
--
--                          end loop;
--                       end;

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
            Child : constant LAL.Ada_Node := Node.Child (i);
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
                        List : constant LAL.Base_Assoc_List := LAL.Base_Assoc_List (Child);
                     begin
                        if not List.Is_Empty_List
                        then
--                             List.Print;
--                             put_Line ("LIST CHILD COUNT: " & Natural'Image (List.Child_Count));
                           for i in 1 .. List.Child_Count
                           loop
                              declare
                                 Pragma_Arg : constant LAL.Pragma_Argument_Assoc := LAL.Pragma_Argument_Assoc (List.Child (i));
                                 Arg        : constant String := to_String (Pragma_Arg.F_Expr.Text);
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

      Ids : constant LAL.Identifier_List := Node.F_Ids;
   begin
      Depth := Depth + 1;

      -- Parse children.
      --
      put_Line (Indent & "Ids Child Count: " & Integer'Image (Ids.Child_Count));

      for i in 1 .. Ids.child_Count
      loop
         declare
            Child         : constant LAL.Identifier := LAL.Identifier (Ids.Child (i));
            Name          : constant String         := LAL.Text (Child.F_Tok);
            new_Exception : constant AdaM.Declaration.of_exception.view := AdaM.Declaration.of_exception.new_Declaration (Name);
         begin
            case current_Section
            is
               when public_Part =>
                  new_Exception.is_Public;
               when private_Part =>
                  new_Exception.is_Public (now => False);
            end case;

            current_Parent.Children.append (new_Exception.all'Access);
            new_Exception.parent_Entity_is (current_Parent);
         end;
      end loop;

      Depth := Depth - 1;
   end parse_Exception;



   function parse_Enumeration (Node : in LAL.Enum_Type_Decl) return AdaM.a_Type.enumeration_type.view
   is

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
            Child : constant LAL.Ada_Node := Node.Child (i);
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
                        List : constant LAL.Enum_Literal_Decl_List := LAL.Enum_Literal_Decl_List (Child);
                     begin
                        for i in 1 .. List.child_Count
                        loop
                           declare
                              Literal : constant LAL.Enum_Literal_Decl := LAL.Enum_Literal_Decl (List.Child (i));
                              Name    : constant String                := to_String (Literal.P_Defining_Name.Text);

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




   function parse_signed_integer_Type (Named : in String;
                                       Node  : in LAL.Signed_Int_Type_Def) return AdaM.a_Type.signed_integer_type.view
   is

      new_Type : constant AdaM.a_Type.signed_integer_type.view := AdaM.a_Type.signed_integer_type.new_Type (Named);

   begin
--        Node.Print;
      Depth := Depth + 1;

      declare
         the_Range : constant LAL.Bin_Op := LAL.Bin_Op (Node.Child (1));
         First     :          Text;
         Last      :          Text;
      begin
         parse_Range (the_Range,  First, Last);

         new_Type.First_is (long_long_Integer'Value (+First));
         new_Type.Last_is  (long_long_Integer'Value (+Last));
      end;

      Depth := Depth - 1;

      return new_Type;
   end parse_signed_integer_Type;



   function parse_floating_point_Type (Named : in String;
                                       Node  : in LAL.Floating_Point_Def) return AdaM.a_Type.floating_point_type.view
   is
      new_Type : constant AdaM.a_Type.floating_point_type.view := AdaM.a_Type.floating_point_type.new_Type (Named);
   begin
--        Node.print;
      Depth := Depth + 1;

      declare
         digits_Text : constant String  := to_String (Node.Child (1).Text);
         the_Digits  : constant Integer := Integer'Value (digits_Text);
      begin
         new_Type.Digits_are (the_Digits);
      end;

      declare
         the_Range : constant LAL.Bin_Op := LAL.Bin_Op (Node.Child (2));
         First     :          Text;
         Last      :          Text;
      begin
         parse_Range (the_Range,  First, Last);

         new_Type.First_is (long_long_Float'Value (+First));
         new_Type.Last_is  (long_long_Float'Value (+Last));
      end;

      Depth := Depth - 1;

      return new_Type;
   end parse_floating_point_Type;



   function parse_fixed_point_Type (Named : in String;
                                    Node  : in LAL.Ordinary_Fixed_Point_Def) return AdaM.a_Type.ordinary_fixed_point_type.view
   is
      new_Type : constant AdaM.a_Type.ordinary_fixed_point_type.view := AdaM.a_Type.ordinary_fixed_point_type.new_Type (Named);
   begin
--        Node.print;
      Depth := Depth + 1;

      declare
         delta_Text : constant String := to_String (Node.Child (1).Text);
--           the_Delta  : constant Float  := Float'Value (delta_Text);
      begin
         null;
         new_Type.Delta_is (delta_Text);
      end;

      declare
         the_Range : constant LAL.Bin_Op := LAL.Bin_Op (Node.Child (2));
         First     :          Text;
         Last      :          Text;
      begin
         parse_Range (the_Range,  First, Last);

         new_Type.First_is (+First);
         new_Type.Last_is  (+Last);
      end;

      Depth := Depth - 1;

      return new_Type;
   end parse_fixed_point_Type;



   function parse_decimal_point_Type (Named : in String;
                                      Node  : in LAL.Decimal_Fixed_Point_Def) return AdaM.a_Type.decimal_fixed_point_type.view
   is
      new_Type : constant AdaM.a_Type.decimal_fixed_point_type.view := AdaM.a_Type.decimal_fixed_point_type.new_Type (Named);
   begin
--        Node.print;
      Depth := Depth + 1;

      declare
         delta_Text : constant String := to_String (Node.Child (1).Text);
      begin
         new_Type.Delta_is (delta_Text);
      end;

      declare
         digits_Text : constant String := to_String (Node.Child (2).Text);
      begin
         new_Type.Digits_is (digits_Text);
      end;

      declare
         the_Range : constant LAL.Bin_Op := LAL.Bin_Op (Node.Child (3));
         First     :          Text;
         Last      :          Text;
      begin
         if the_Range /= null
         then
            parse_Range (the_Range,  First, Last);

            new_Type.First_is (+First);
            new_Type.Last_is  (+Last);
         end if;
      end;

      Depth := Depth - 1;

      return new_Type;
   end parse_decimal_point_Type;





   function parse_derived_Type (Named : in String;
                                Node  : in LAL.Derived_Type_Def) return AdaM.a_Type.derived_type.view
   is
      new_Type : constant AdaM.a_Type.derived_type.view := AdaM.a_Type.derived_type.new_Type (Named);
   begin
--        Node.Print;
      Depth := Depth + 1;

      declare
         the_Subtype    : constant LAL.Subtype_Indication       := LAL.Subtype_Indication (Node.Child (4));
         new_Indication : constant AdaM.subtype_Indication.view := AdaM.subtype_Indication.new_Indication;
      begin
         parse_subtype_Indication (the_Subtype, new_Indication.all);
         new_Type.parent_Subtype_is (new_Indication);
      end;

      Depth := Depth - 1;

      return new_Type;
   end parse_derived_Type;



   procedure parse_record_Component (Into : in out AdaM.a_Type.record_type.item'Class;
                                     From : in     LAL.Component_Decl)
   is
      the_Record     : AdaM.a_Type.record_type.item'Class renames Into;
      component_Decl : LAL.Component_Decl                 renames From;

      component_Def  : constant LAL.Component_Def      := LAL.Component_Def (component_Decl.Child (2));
      the_Type       : constant LAL.Subtype_Indication := LAL.Subtype_Indication (Component_Def.F_Type_Expr);
      the_Default    : LAL.Ada_Node                    := component_Decl.Child (3);

      Name           : constant String                     := to_String (component_Decl.P_Defining_Name.Text);
      the_Component  : constant AdaM.record_Component.view := AdaM.record_Component.new_Component (Name);
--        the_Indication :          Subtype_Indication   .view := AdaM.subtype_Indication.new_Indication;
   begin
      the_Component.Definition.is_Aliased (now => Component_Def.F_Has_Aliased);

      parse_subtype_Indication (the_Type, the_Component.Definition.subtype_Indication.all);
--        parse_subtype_Indication (the_Type, the_Indication.all);
--        the_Component.Definition.subtype_Indication_is (the_Indication);

      if the_Default /= null
      then
         the_Component.Default_is (to_String (the_Default.Text));
      end if;

      the_Record.Children.append (the_Component.all'Access);
   end parse_record_Component;



   function parse_record_Type (Named : in String;
                               Node  : in LAL.Record_Type_Def) return AdaM.a_Type.record_type.view
   is
      new_Type : constant AdaM.a_Type.record_type.view := AdaM.a_Type.record_type.new_Type (Named);
   begin
--        Node.print;
      Depth := Depth + 1;

      new_Type.is_Abstract (now => Node.F_Has_Abstract);
      new_Type.is_Tagged   (now => Node.F_Has_Tagged);
      new_Type.is_Limited  (now => Node.F_Has_Limited);

      declare
         the_Record : constant LAL.Record_Def    := LAL.Record_Def    (Node.Child (4));
         Components : constant LAL.Ada_Node_List := LAL.Ada_Node_List (the_Record.Child (1).Child (1));
         Component  :          LAL.Component_Decl;
      begin
         if Components.Child (1).Kind = LAL.Ada_Null_Component_Decl
         then
            null;
         else
            for i in 1 .. Components.child_Count
            loop
               Component := LAL.Component_Decl (Components.Child (i));
               parse_record_Component (new_Type.all, Component);
            end loop;
         end if;
      end;

      Depth := Depth - 1;

      return new_Type;
   end parse_record_Type;



   function parse_access_Type (Named : in String;
                               Node  : in LAL.Type_Access_Def) return AdaM.a_Type.access_type.view
   is
      use AdaM.a_Type.access_type;
      new_Type : constant AdaM.a_Type.access_type.view := AdaM.a_Type.access_type.new_Type (is_access_to_Object => True);
   begin
--        Node.print;
      Depth := Depth + 1;

      new_Type.Name_is (Named);
      new_Type.has_not_Null (now => Node.F_Has_Not_Null);

      if    Node.F_Has_All      then   new_Type.Modifier_is (all_Modifier);
      elsif Node.F_Has_Constant then   new_Type.Modifier_is (constant_Modifier);
      else                             new_Type.Modifier_is (None);
      end if;

      parse_subtype_Indication (Node           => Node.F_Subtype_Indication,
                                new_Indication => new_Type.Indication.all);

      Depth := Depth - 1;

      return new_Type;
   end parse_access_Type;



   function parse_Type (Node : in LAL.Type_Decl) return AdaM.a_Type.view
   is
      use ada.Characters.Conversions;

      Name : constant String := to_String (Node.P_Defining_Name.Text);
      --        Ids : LAL.Identifier_List := Node.F_Ids;

      Result : AdaM.a_Type.view;
   begin
      Depth := Depth + 1;

      log ("Name: '" & Name & "'");

      Node.print;

      -- Parse children.
      --
      put_Line (Indent & "Child Count: " & Integer'Image (Node.Child_Count));

      for i in 1 .. Node.child_Count
      loop
         declare
            Child : constant LAL.Ada_Node := Node.Child (i);
         begin
            if Child = null
            then
               log ("Null Node");

            else
               case Child.Kind
               is
                  when LAL.Ada_Signed_Int_Type_Def =>
                     log ("parsing Ada_Signed_Int_Type_Def");
                     Result := AdaM.a_Type.view (parse_signed_integer_Type (named => Name, node => LAL.Signed_Int_Type_Def (Child)));
                     exit;

                  when LAL.Ada_Floating_Point_Def =>
                     log ("parsing Ada_Floating_Point_Def");
                     Result := AdaM.a_Type.view (parse_floating_point_Type (named => Name, node => LAL.Floating_Point_Def (Child)));
                     exit;

                  when LAL.Ada_Ordinary_Fixed_Point_Def =>
                     log ("parsing Ada_Ordinary_Fixed_Point_Def");
                     Result := AdaM.a_Type.view (parse_fixed_point_Type (named => Name, node => LAL.Ordinary_Fixed_Point_Def (Child)));
                     exit;

                  when LAL.Ada_Decimal_Fixed_Point_Def =>
                     log ("parsing Ada_Decimal_Fixed_Point_Def");
                     Result := AdaM.a_Type.view (parse_decimal_point_Type (named => Name, node => LAL.Decimal_Fixed_Point_Def (Child)));
                     exit;

                  when LAL.Ada_Array_Type_Def =>
                     log ("parsing Ada_Array_Type_Def");

                     Result := AdaM.a_Type.view (parse_array_Type (named => Name, node => LAL.Array_Type_Def (Child)));
                     exit;

                  when LAL.Ada_Record_Type_Def =>
                     log ("parsing Ada_Record_Type_Def");

                     Result := AdaM.a_Type.view (parse_record_Type (named => Name, node => LAL.Record_Type_Def (Child)));
                     exit;

                  when LAL.Ada_Private_Type_Def =>
                     log ("parsing Ada_Private_Type_Def");

                     declare
                        new_Type : constant AdaM.a_Type.private_type.view := AdaM.a_Type.private_type.new_Type (Name);
                     begin
                        Result := new_Type.all'Access;
                        exit;
                     end;

                  when LAL.Ada_Derived_Type_Def =>
                     log ("parsing Ada_Derived_Type_Def");

                     Result := AdaM.a_Type.view (parse_derived_Type (named => Name, node => LAL.Derived_Type_Def (Child)));
                     exit;

--                       declare
--                          new_Type : constant AdaM.a_Type.derived_type.view := AdaM.a_Type.derived_type.new_Type (Name);
--                       begin
--                          return new_Type.all'Access;
--                       end;

                  when LAL.Ada_Type_Access_Def =>
                     log ("parsing Ada_Type_Access_Def");

                     Result := AdaM.a_Type.view (parse_access_Type (named => Name, node => LAL.Type_Access_Def (Child)));
                     exit;

                  when others =>
                     Put_Line (Indent & "*** parse_type *** ...  Skip pre-processing of " & Short_Image (Child)
                               & "   Kind => " & LAL.Ada_Node_Kind_Type'Image (Child.Kind));
               end case;
            end if;
         end;
      end loop;

      Depth := Depth - 1;

      return Result;
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

      current_Section := public_Part;

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
      use type AdaM.Entity.view;

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

         when LAL.Ada_Public_Part =>
            log ("Processing an Ada_Public_Part");
            current_Section := public_Part;

         when LAL.Ada_Private_Part =>
            log ("Processing an Ada_Private_Part");
            current_Section := private_Part;

--           when LAL.Ada_Package_Body =>
--              log ("Processing an Ada_Package_Body");
--              Print_Navigation
--                (Indent & "Decl", Node, LAL.Package_Body (Node).P_Decl_Part);
--
--           when LAL.Ada_Generic_Package_Decl =>
--              Print_Navigation
--                (Indent & "Body", Node,
--                 LAL.Generic_Package_Decl (Node).P_Body_Part);
--
--              --  Subprograms
--              --
--           when LAL.Ada_Subp_Decl =>
--              Print_Navigation
--                (Indent & "Body", Node, LAL.Subp_Decl (Node).P_Body_Part);
--
--           when LAL.Ada_Subp_Body =>
--              Print_Navigation
--                (Indent & "Decl", Node, LAL.Subp_Body (Node).P_Decl_Part);
--
--           when LAL.Ada_Generic_Subp_Decl =>
--              Print_Navigation
--                (Indent & "Body", Node,
--                 LAL.Generic_Subp_Decl (Node).P_Body_Part);

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
            declare
               use adam.a_Type;
               new_Type : AdaM.a_Type.view := parse_Type (LAL.Type_Decl (Node));
            begin
               if new_Type /= null
               then
                  new_Entity := new_Type.all'Access;
               else
                  new_Line (3);
                  put_Line ("*** WARNING *** : unable to parse type for node =>");
                  Node.print;
                  new_Line (3);
               end if;
            end;
            skip_Children := True;

         when LAL.Ada_Subtype_Decl =>
            log ("Processing an Ada_Subtype_Decl");

            declare
               Name         : constant String                     := to_String (LAL.Subtype_Decl (Node).P_Defining_Name.Text);
               new_Subtype  : constant AdaM.a_Type.a_subtype.view := AdaM.a_Type.a_subtype.new_Subtype (Name);
            begin
               log ("Subtype name: '" & Name & "'");

               parse_subtype_Indication (LAL.Subtype_Indication (Node.Child (2)),
                                         new_Subtype.Indication.all);

               new_Entity := new_Subtype.all'Access;
            end;
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

         case current_Section
         is
            when public_Part =>
               new_Entity.is_Public;

            when private_Part =>
               new_Entity.is_Public (now => False);
         end case;

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
         Node : constant LAL.Ada_Node := LAL.Root (Unit);
      begin
         process (Node);

         if not At_Least_Once then
            Put_Line ("<no node to process>");
         end if;

         New_Line;
      end;
   end Process_File;




--     procedure Print_Navigation (Part_Name  : String;
--                                 Orig, Dest : access LAL.Ada_Node_Type'Class)
--     is
--     begin
--        if Dest = null then
--           Put_Line
--             (Short_Image (Orig) & " has no " & To_Lower (Part_Name));
--        else
--           Put_Line
--             (Part_Name & " of " & Short_Image (Orig) & " is "
--              & Short_Image (Dest)
--              & " [" & LAL.Get_Filename (Dest.Get_Unit) & "]");
--        end if;
--     end Print_Navigation;


   ----------------------------
   -- Is_Navigation_Disabled --
   ----------------------------

--     function Is_Navigation_Disabled (N : LAL.Ada_Node) return Boolean
--     is
--
--        function Lowercase_Name (Id : LAL.Identifier) return String is
--          (To_Lower (Langkit_Support.Text.Image (LAL.Text (Id.F_Tok))));
--
--        function Has_Disable_Navigation
--          (Aspects : LAL.Aspect_Spec) return Boolean;
--
--        ----------------------------
--        -- Has_Disable_Navigation --
--        ----------------------------
--
--        function Has_Disable_Navigation
--          (Aspects : LAL.Aspect_Spec) return Boolean
--        is
--           use type LAL.Ada_Node_Kind_Type;
--           use type LAL.Aspect_Spec;
--        begin
--           if Aspects = null then
--              return False;
--           end if;
--           for Child of Aspects.F_Aspect_Assocs.Children loop
--              declare
--                 Assoc : constant LAL.Aspect_Assoc := LAL.Aspect_Assoc (Child);
--              begin
--                 if Assoc.F_Id.Kind = LAL.Ada_Identifier then
--                    declare
--                       Id : constant LAL.Identifier :=
--                         LAL.Identifier (Assoc.F_Id);
--                    begin
--                       return Lowercase_Name (Id) = "disable_navigation";
--                    end;
--                 end if;
--              end;
--           end loop;
--           return False;
--        end Has_Disable_Navigation;
--
--     begin
--        case N.Kind is
--           when LAL.Ada_Base_Package_Decl =>
--              return Has_Disable_Navigation
--                (LAL.Base_Package_Decl (N).F_Aspects);
--
--           when others =>
--              return False;
--        end case;
--     end Is_Navigation_Disabled;

   Unit : LAL.Analysis_Unit := LAL.get_from_File (Ctx, File);

begin
--     Ctx := LAL.Create;

   process_File (Unit, File);

--     Environ.add_package_Standard;
--
--  --     for Each of ada_Family
--  --     loop
--  --        declare
--  --           Prefix : constant String   := "/usr/lib/gcc/x86_64-pc-linux-gnu/7.2.0/adainclude/";
--  --           Arg    : constant String   := Each.all;
--  --           Unit   : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, Prefix & Arg);
--  --           --           Unit : LAL.Analysis_Unit := LAL.Get_From_File (Ctx, "standard.ads");
--  --        begin
--  --           process_File (Unit, Prefix & Arg);
--  --        end;
--  --     end loop;
--
--     declare
--        Prefix : constant String   := "/eden/forge/applet/tool/aIDE/applet/aide/test/";
--        Arg    : constant String   := "test_package.ads";
--        Unit   : constant LAL.Analysis_Unit := LAL.Get_From_File (Ctx, Prefix & Arg);
--     begin
--        process_File (Unit, Prefix & Arg);
--     end;

   LAL.Destroy (Ctx);
   put_Line ("Done.");
   new_Line;

--     return Environ;
end AdaM.parse;
