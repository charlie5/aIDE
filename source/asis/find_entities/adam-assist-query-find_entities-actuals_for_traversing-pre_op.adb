with
     AdaM,
     AdaM.Entity,
     AdaM.a_Package,
     AdaM.Subprogram,
     AdaM.Declaration.of_exception,
     AdaM.a_Type.enumeration_type,
     AdaM.a_Type.signed_integer_type,
     AdaM.a_Type.modular_type,
     AdaM.a_Type.floating_point_type,
     AdaM.a_Type.ordinary_fixed_point_type,
     AdaM.a_Type.decimal_fixed_point_type,
     AdaM.a_Type.access_type,
     AdaM.a_Type.unconstrained_array_type,
     AdaM.a_Type.constrained_array_type,
     AdaM.a_Type.record_type,
     AdaM.a_Type.tagged_record_type,
     AdaM.a_Type.derived_type,
     AdaM.a_Type.derived_record_extension_type,
     AdaM.a_Type.interface_type,
     AdaM.a_Type.task_type,
     AdaM.a_Type.protected_type,
     AdaM.a_Type.a_subtype;

with Ada.Wide_Text_IO;
with Ada.Characters.Handling;
with Ada.Exceptions;
with ada.Strings.fixed;

with Asis.Exceptions;
with Asis.Errors;
with Asis.Implementation;
with Asis.Elements;
with asis.Declarations,
     asis.Expressions;

with AdaM.Assist.Query.find_Entities.Metrics;
with Asis;
with Asis.Declarations;
with Asis.Compilation_Units;
with ada.Text_IO;


separate (AdaM.Assist.Query.find_Entities.Actuals_for_traversing)

procedure Pre_Op (Element :        Asis.Element;
                  Control : in out Asis.Traverse_Control;
                  State   : in out Traversal_State)
is
   use Asis,
       asis.Elements,
       asis.Declarations,

       Ada.Characters.Handling,
       Ada.Wide_Text_IO;

   package Metrics renames AdaM.Assist.Query.find_Entities.Metrics;

   Argument_Kind        : Asis.Element_Kinds;
   the_declaration_Kind : Asis.declaration_Kinds;

--     Parent     : Source.Entity_View;
--     new_Entity : Source.Entity_View;

--     Parent     : AdaM.Entity.view;
   new_Entity : AdaM.Entity.view;

   use type Source.Entity_View;
   use type Entity.view;



begin
   if not Is_Nil (State.ignore_Starter)
   then
      return;
   end if;

--     if not State.parent_Stack.is_Empty
--     then
--        Parent := State.parent_Stack.last_Element;
--     end if;

   --  Note, that the code below may be rewritten in more compact way (with
   --  the same functionality). But we prefer to go step-by-step,
   --  demonstrating the important ASIS queries

   Argument_Kind        := Asis.Elements.    element_Kind (Element);
   the_declaration_Kind := Asis.Elements.declaration_Kind (Element);

   ada.text_IO.put_Line ("Pre-Op: Processing kind (" & Asis.Element_Kinds'Image (Argument_Kind)
                         & ")     declaration kind is (" & Asis.declaration_Kinds'Image (the_declaration_Kind) & ")");


--     if the_declaration_Kind = asis.a_package_Instantiation
--     then
--        State.ignore_Starter := Element;
--        return;
--     end if;

   case Argument_Kind
   is
      when Asis.A_Statement =>
         State.ignore_Starter := Element;

      when Asis.A_Definition =>
         State.ignore_Starter := Element;

      when Asis.A_Declaration =>
         declare
            use asis.Compilation_Units;

            the_Declaration : constant asis.Declaration        := asis.Declaration (Element);
            the_Kind        : constant Asis.Declaration_Kinds  := asis.Elements.Declaration_Kind (the_Declaration);

            the_Names       : constant asis.Defining_Name_List := Names (Element);

            the_Unit        : constant asis.Compilation_Unit   := Enclosing_Compilation_Unit (the_Declaration);
            the_unit_Name   : constant String                  := to_String (Unit_Full_Name (the_Unit));

            the_Parent      : constant asis.Element            := enclosing_Element (Element);

            function full_name_Prefix return String
            is
               parent_Name  : constant String := to_String (Defining_Name_Image (Names (the_Parent) (1)));
            begin
               if the_unit_Name = parent_Name then
                  return the_unit_Name;
               else
                  return the_unit_Name & "." & parent_Name;
               end if;
            end full_name_Prefix;

         begin
            case the_Kind
            is
               when Asis.A_Package_Declaration =>
                  declare
                     use ada.Strings, ada.Strings.Fixed, ada.Strings.Unbounded;

                     package_Name    : constant String              := to_String (Defining_Name_Image (the_Names (1)));
                     final_dot_Index : constant Natural             := Index (package_Name, ".", Backward);
                     parent_Name     :          Unbounded_String    := +package_Name (1 .. final_dot_Index - 1);
                     new_Package     : constant AdaM.a_Package.view := AdaM.a_Package.new_Package (package_Name);
                     parent_Package  :          AdaM.a_Package.view;
                  begin
                     if package_Name = "Standard"
                     then
                        Metrics.Environment.standard_Package_is (new_Package);
                     else
                        if not Is_Nil (the_Parent)
                        then
                           parent_Name := +full_name_Prefix;
                        end if;

                        if parent_Name = ""
                        then
                           parent_Package := Metrics.Environment.standard_Package;
                        else
                           parent_Package := Metrics.all_Packages.Element (parent_Name);
                        end if;

                        parent_Package.add_Child (new_Package);
--                       new_Package   .Parent_is (parent_Package);
                     end if;

                     Metrics.all_Packages.insert (+package_Name, new_Package);

                     new_Entity := new_Package.all'Access;
--                    Metrics.current_package_Declaration.Name_is (package_Name);
                  end;

               when Asis.A_Procedure_Body_Declaration =>
                  declare
                     use ada.Strings, ada.Strings.Fixed, ada.Strings.Unbounded;

                     procedure_Name  : constant String              := to_String (Defining_Name_Image (the_Names (1)));
                     final_dot_Index : constant Natural             := Index (procedure_Name, ".", Backward);
                     parent_Name     :          Unbounded_String    := +procedure_Name (1 .. final_dot_Index - 1);
                     new_Procedure   : constant AdaM.Subprogram.view := AdaM.Subprogram.new_Subprogram (procedure_Name);
                     parent_Package  :          AdaM.a_Package.view;
                  begin
                     if not Is_Nil (the_Parent)
                     then
                        parent_Name := +full_name_Prefix;
                     end if;

--                       if parent_Name = ""
--                       then
--                          parent_Package := Metrics.Environment.standard_Package;
--                       else
--                          parent_Package := Metrics.all_Packages.Element (parent_Name);
--                       end if;

                     new_Entity := new_Procedure.all'Access;
--                    Metrics.current_package_Declaration.Name_is (package_Name);
                  end;

               when asis.An_Exception_Declaration =>
                  declare
--                    use Adam;
--                    the_Unit      : constant asis.Compilation_Unit := Asis.Elements.Enclosing_Compilation_Unit (the_Declaration);
--                    the_unit_Name : constant Wide_String           := Asis.Compilation_Units.Unit_Full_Name (the_Unit);

                     Names    : constant asis.Defining_Name_List := Asis.Declarations.Names (Element);
                     the_Name :          String                  := to_String (Asis.Declarations.Defining_Name_Image (Names (1)));

                     new_Exception : AdaM.Declaration.of_exception.view := Adam.Declaration.of_exception.new_Declaration (the_Name);
                  begin
                     new_Entity := new_Exception.all'Access;
                  end;

               when asis.An_Ordinary_Type_Declaration =>
                  declare
                     use AdaM;

                     the_Name          :          asis.Defining_Name;
                     the_Grandparent   : constant asis.Element         := enclosing_Element (the_Parent);
                     parent_Name       : constant String               := to_String (Defining_Name_Image (Names (the_Parent) (1)));

                     the_Type          : constant asis.Type_Definition := asis.Type_Definition  (the_Declaration);
                     the_Type_View     : constant asis.Declaration     := Type_Declaration_View (the_Declaration);
                  begin
                     for i in the_Names'Range
                     loop
                        the_Name := the_Names (i);

                        declare
                           the_name_Image : constant String  := to_String (Defining_Name_Image (the_Name));
                           add_Type       :          Boolean := True;
                        begin
                           -- Don't add the type if it is a generic parameter.
                           --
                           if declaration_Kind (the_Grandparent) = a_package_Instantiation
                           then
                              declare
                                 use asis.Expressions;

                                 grandparent_Name :          String                := to_String (Defining_Name_Image (Names (the_Grandparent) (1)));
                                 assocs           : constant asis.Association_List := Generic_Actual_Part (the_Grandparent, True);
                                 param            :          asis.Element;
                              begin
                                 for i in assocs'Range
                                 loop
                                    param := Formal_Parameter (assocs (i));

                                    if to_Lower (to_String (Defining_Name_Image (param))) = to_Lower (the_name_Image)
                                    then
                                       add_Type := False;
                                    end if;
                                 end loop;
                              end;
                           end if;

                           if add_Type
                           then
                              declare
                                 use ada.Strings.unbounded,
                                     AdaM.a_Type,
                                     AdaM.Source;

                                 full_Name : Text;
                                 new_Type  : AdaM.a_Type.view;
                              begin
                                 if the_unit_Name = parent_Name
                                 then
                                    Set_Unbounded_String (full_Name, the_unit_Name & "." & the_name_Image);
                                 else
                                    Set_Unbounded_String (full_Name, the_unit_Name & "." & parent_Name & "." & the_name_Image);
                                 end if;

                                 case asis.Elements.Type_Kind (the_Type_View)
                                 is
                                 when An_Enumeration_Type_Definition =>
                                    declare
                                       new_enum_Type : constant AdaM.a_Type.enumeration_type.view
                                         := AdaM.a_Type.enumeration_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_enum_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Signed_Integer_Type_Definition =>
                                    declare
                                       new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
                                         := AdaM.a_Type.signed_integer_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_integer_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Modular_Type_Definition =>
                                    declare
                                       new_modular_Type : constant AdaM.a_Type.modular_type.view
                                         := AdaM.a_Type.modular_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_modular_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Floating_Point_Definition =>
                                    declare
                                       new_float_Type : constant AdaM.a_Type.floating_point_type.view
                                         := AdaM.a_Type.floating_point_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_float_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when An_Ordinary_Fixed_Point_Definition =>
                                    declare
                                       new_ordinary_fixed_Type : constant AdaM.a_Type.ordinary_fixed_point_type.view
                                         := AdaM.a_Type.ordinary_fixed_point_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_ordinary_fixed_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Decimal_Fixed_Point_Definition =>
                                    declare
                                       new_decimal_fixed_Type : constant AdaM.a_Type.decimal_fixed_point_type.view
                                         := AdaM.a_Type.decimal_fixed_point_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_decimal_fixed_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when An_Access_Type_Definition =>
                                    declare
                                       new_access_Type : constant AdaM.a_Type.access_type.view
                                         := AdaM.a_Type.access_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_access_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when An_Unconstrained_Array_Definition =>
                                    declare
                                       new_array_Type : constant AdaM.a_Type.unconstrained_array_type.view
                                         := AdaM.a_Type.unconstrained_array_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_array_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Constrained_Array_Definition =>
                                    declare
                                       new_array_Type : constant AdaM.a_Type.constrained_array_type.view
                                         := AdaM.a_Type.constrained_array_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_array_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Record_Type_Definition =>
                                    declare
                                       new_record_Type : constant AdaM.a_Type.record_type.view
                                         := AdaM.a_Type.record_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_record_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Tagged_Record_Type_Definition =>
                                    declare
                                       new_record_Type : constant AdaM.a_Type.tagged_record_type.view
                                         := AdaM.a_Type.tagged_record_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_record_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Derived_Type_Definition =>
                                    declare
                                       new_derived_Type : constant AdaM.a_Type.derived_type.view
                                         := AdaM.a_Type.derived_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_derived_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Derived_Record_Extension_Definition =>
                                    declare
                                       new_derived_Type : constant AdaM.a_Type.derived_record_extension_type.view
                                         := AdaM.a_Type.derived_record_extension_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_derived_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when An_Interface_Type_Definition =>
                                    declare
                                       new_interface_Type : constant AdaM.a_Type.interface_type.view
                                         := AdaM.a_Type.interface_type.new_Type (Name => +full_Name);
                                    begin
                                       new_Type := new_interface_Type.all'Access;
                                    end;

                                    new_Entity := new_Type.all'Access;


                                 when A_Root_Type_Definition =>
                                    ada.Text_IO.put_Line ("*******  A_Root_Type_Definition  *********   " & (+full_Name));


                                 when Not_A_Type_Definition =>
                                    ada.Text_IO.put_Line ("*******  Not_A_Type_Definition  *********   " & (+full_Name));

                                 end case;

                                 if new_Type /= null
                                 then
                                    Metrics.all_Types.append (new_Type);
                                 end if;
                              end;
                           end if;
                        end;
                     end loop;
                  end;


               when A_Subtype_Declaration =>
                  declare
                     full_Name   : constant String
                       := full_name_Prefix & "." & to_String (Defining_Name_Image (the_Names (1)));

                     new_Subtype : constant AdaM.a_Type.a_subtype.view
                       := AdaM.a_Type.a_subtype.new_Type (Name => full_Name);
                  begin
                     Metrics.all_Types.append (new_Subtype.all'Access);
                     new_Entity := new_Subtype.all'Access;
                  end;


               when A_Task_Type_Declaration =>
                  declare
                     full_Name : constant String
                       := full_name_Prefix & "." & to_String (Defining_Name_Image (the_Names (1)));

                     new_Type  : constant AdaM.a_Type.task_type.view
                       := AdaM.a_Type.task_type.new_Type (Name => full_Name);
                  begin
                     Metrics.all_Types.append (new_Type.all'Access);
                     new_Entity := new_Type.all'Access;
                  end;


               when A_Protected_Type_Declaration =>
                  declare
                     full_Name : constant String
                       := full_name_Prefix & "." & to_String (Defining_Name_Image (the_Names (1)));

                     new_Type  : constant AdaM.a_Type.protected_type.view
                       := AdaM.a_Type.protected_type.new_Type (Name => full_Name);
                  begin
                     Metrics.all_Types.append (new_Type.all'Access);
                     new_Entity := new_Type.all'Access;
                  end;

               when others =>
                  State.ignore_Starter := Element;
            end case;
         end;

      when others =>
         State.ignore_Starter := Element;
   end case;


   if not Is_Nil (State.ignore_Starter)
   then
      return;   -- We are now ignoring, so do no more.
   end if;


   if Metrics.current_Parent = null
   then
      Metrics.compilation_Unit.Entity_is (new_Entity);

      ada.Text_IO.put_Line ("Lowering Metrics.current_Parent from null to " & new_Entity.Name);
      new_Entity.parent_Entity_is (null);
      Metrics.current_Parent := new_Entity;
   else
      Metrics.current_Parent.Children.append (new_Entity);

      ada.Text_IO.put_Line ("Lowering Metrics.current_Parent from " & Metrics.current_Parent.Name &
                              " to " & new_Entity.Name);
      new_Entity.parent_Entity_is (Metrics.current_Parent);
      Metrics.current_Parent := new_Entity;
   end if;

--        State.parent_Stack.append (new_Entity);   -- Allow children to know their parent.

exception

   when Ex : Asis.Exceptions.ASIS_Inappropriate_Context          |
        Asis.Exceptions.ASIS_Inappropriate_Container        |
        Asis.Exceptions.ASIS_Inappropriate_Compilation_Unit |
        Asis.Exceptions.ASIS_Inappropriate_Element          |
        Asis.Exceptions.ASIS_Inappropriate_Line             |
        Asis.Exceptions.ASIS_Inappropriate_Line_Number      |
        Asis.Exceptions.ASIS_Failed                         =>

      Ada.Wide_Text_IO.Put ("Pre_Op : ASIS exception (");

      Ada.Wide_Text_IO.Put (Ada.Characters.Handling.To_Wide_String (
                            Ada.Exceptions.Exception_Name (Ex)));

      Ada.Wide_Text_IO.Put (") is raised");
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

      Ada.Wide_Text_IO.Put ("Pre_Op : ");

      Ada.Wide_Text_IO.Put (Ada.Characters.Handling.To_Wide_String (
                            Ada.Exceptions.Exception_Name (Ex)));

      Ada.Wide_Text_IO.Put (" is raised (");

      Ada.Wide_Text_IO.Put (Ada.Characters.Handling.To_Wide_String (
                            Ada.Exceptions.Exception_Information (Ex)));

      Ada.Wide_Text_IO.Put (")");
      Ada.Wide_Text_IO.New_Line;

end Pre_Op;
