with
     AdaM.Entity,
     AdaM.Assist,
     AdaM.a_Pragma,
     AdaM.Environment,
     AdaM.Declaration.of_package,
     AdaM.a_Type.enumeration_type,
     AdaM.a_Type.signed_integer_type,
     AdaM.a_Type.a_subtype,
     AdaM.a_Type.floating_point_type,
     AdaM.a_Type.array_type,
     AdaM.a_Type.ordinary_fixed_point_type,

     Ada.Text_IO,
     Ada.Tags,
     Ada.Strings.fixed;

use Ada.Text_IO;


package body AdaM.Environment
is

   procedure add (Self : in out Item;   Unit : in compilation_Unit.view)
   is
   begin
      Self.Units.append (Unit);
   end add;



   procedure clear (Self : in out Item)
   is
   begin
      Self.Units.Clear;
   end clear;



   function Length (Self : in Item) return Natural
   is
   begin
      return Natural (Self.Units.Length);
   end Length;



   function Unit   (Self : in Item;   Index : Positive) return compilation_Unit.View
   is
   begin
      return Self.Units.Element (Index);
   end Unit;



   procedure standard_package_is (Self : in out Item;   Now : in AdaM.a_Package.view)
   is
   begin
      Self.standard_Package := Now;
   end standard_package_is;



   function standard_Package (Self : in Item) return AdaM.a_Package.view
   is
   begin
      return Self.standard_Package;
   end standard_Package;



   function all_Types (Self : in Item) return AdaM.a_Type.Vector
   is
      the_Types  : AdaM.a_Type.Vector;

      the_Unit   : AdaM.compilation_Unit.view;
      pragma Unreferenced (the_Unit);
--        the_Entity : AdaM.Source.Entity_View;

      use type AdaM.a_Type.view;
   begin
      for i in 1 .. Self.Length
      loop
         the_Unit := Self.Units.Element (i);

--           for j in 1 .. the_Unit.Length
--           loop
--              the_Entity := the_Unit.Entity (j);
--
--              if the_Entity.all in AdaM.a_Type.item'Class
--              then
--                 the_Types.append (AdaM.a_Type.view (the_Entity));
--              end if;
--           end loop;
      end loop;

      return the_Types;
   end all_Types;





--     -- TODO: Move these to AdaM.Assist.
--
--     function parent_Name (Identifier : in String) return String
--     is
--        use Ada.Strings,
--            Ada.Strings.fixed;
--        I : constant Natural := Index (Identifier, ".", going => Backward);
--     begin
--        if I = 0
--        then
--           return "Standard";
--        end if;
--
--        return Identifier (Identifier'First .. I - 1);
--     end parent_Name;
--
--
--
--     function simple_Name (Identifier : in String) return String
--     is
--        use Ada.Strings,
--            Ada.Strings.fixed;
--        I : constant Natural := Index (Identifier, ".", going => Backward);
--     begin
--        if I = 0
--        then
--           return Identifier;
--        end if;
--
--        return Identifier (I + 1 .. Identifier'Last);
--     end simple_Name;
--
--
--
--     function Split (Identifier : in String) return text_Lines
--     is
--        use Ada.Strings,
--            Ada.Strings.fixed;
--
--        First : Natural := Identifier'First;
--        Last  : Natural;
--
--        I     : Natural;
--        Lines : text_Lines;
--     begin
--        loop
--           I := Index (Identifier, ".", from => First);
--
--           if I = 0
--           then
--              Last := Identifier'Last;
--              Lines.append (+Identifier (First .. Last));
--              exit;
--           end if;
--
--           Last  := I - 1;
--           Lines.append (+Identifier (First .. Last));
--           First := I + 1;
--        end loop;
--
--        return Lines;
--     end Split;



   function  find (Self : in Item;   Identifier : in AdaM.Identifier) return AdaM.a_Package.view
   is
      use AdaM.Assist;
      the_Package : AdaM.a_Package.view := Self.standard_Package;
   begin
      if Identifier /= "Standard"
      then
         declare
            use type AdaM.a_Package.view;
            Names : constant text_Lines := Split (Identifier);
         begin
            for Each of Names
            loop
               the_Package := the_Package.child_Package (+Each);
               exit when the_Package = null;
            end loop;
         end;
      end if;

      return the_Package;
   end find;



   function  fetch (Self : in Item;   Identifier : in AdaM.Identifier) return AdaM.a_Package.view
   is
      use AdaM.Assist;
      use type AdaM.a_Package.view;

      the_Package : AdaM.a_Package.view := Self.standard_Package;
      Parent      : AdaM.a_Package.view;
      Names       : constant text_Lines := Split (Identifier);
   begin
      if Identifier = "Standard"
      then
         return the_Package;
      end if;

      for Each of Names
      loop
         Parent      := the_Package;
         the_Package := the_Package.child_Package (+Each);

         if the_Package = null
         then
            -- Create a new package.
            --
            the_Package := AdaM.a_Package.new_Package (Parent.Name & "." & (+Each));
            the_Package.Parent_is (Parent);
            Parent.add_Child (the_Package);
         end if;
      end loop;

      return the_Package;
   end fetch;



   function  find (Self : in Item;   Identifier : in AdaM.Identifier) return AdaM.a_Type.view
   is
      use AdaM.Assist;
      the_Package : constant AdaM.a_Package.view := Self.find (parent_Name (Identifier));
   begin
      return the_Package.find (simple_Name (Identifier));
   end find;



   function  find (Self : in Item;   Identifier : in AdaM.Identifier) return AdaM.Declaration.of_exception.view
   is
      use AdaM.Assist;
      the_Package : constant AdaM.a_Package.view := Self.find (parent_Name (Identifier));
   begin
      return the_Package.find (simple_Name (Identifier));
   end find;



   procedure print (Self : in Item)
   is
      use Ada.Strings.fixed;
      the_Unit   : AdaM.compilation_Unit.view;
--        the_Entity : AdaM.Source.Entity_View;

--        Depth      : Natural := 0;
--
--        function Indent return String
--        is
--        begin
--           return Depth * "   ";
--        end Indent;

   begin
      put_Line ("Environment:");

      for i in 1 .. Self.Length
      loop
         the_Unit := Self.Unit (i);

         New_Line (2);
         ada.Text_IO.put_Line ("Unit.Name = " & the_Unit.Name);

--           for i in 1 .. the_Unit.Length
--           loop
--              the_Entity := the_Unit.Entity (i);
--
--              Depth := Depth + 1;
--  --              ada.Text_IO.put_Line (Indent & "Entity : " & the_Entity.Name & "   Tag = " & ada.Tags.Expanded_Name (the_Entity.all'Tag));
--              Depth := Depth - 1;
--           end loop;
      end loop;

      new_Line;
      put_Line ("End Environment:");
   end print;



   procedure print_Entities (Self : in Item)
   is
      use Ada.Strings.fixed;

      the_Unit   : AdaM.compilation_Unit.view;
      top_Entity : AdaM.Entity.view;

      Depth      : Natural := 0;

      function Indent return String
      is
      begin
         return Depth * "   ";
      end Indent;

      procedure print (the_Entity : in Entity.view)
      is
      begin
         Depth := Depth + 1;
         put_Line (Indent
                   & "Entity.Name : "             & (+the_Entity.Name)
                   & "                    Tag = " & Ada.Tags.Expanded_Name (the_Entity.all'Tag));
         Depth := Depth - 1;

         for Each of the_Entity.Children.all
         loop
            print (Each);
         end loop;
      end print;

   begin
      put_Line ("Environment:");

      for i in 1 .. Self.Length
      loop
         the_Unit   := Self.Unit (i);
         top_Entity := the_Unit.Entity;

         New_Line (2);
         put_Line ("Unit.Name = " & the_Unit.Name);
         put_Line ("Top Entity.Name = " & (+top_Entity.Name));

         print (top_Entity);
      end loop;

      new_Line;
      put_Line ("End Environment:");
   end print_Entities;




   procedure add_package_Standard (Self : in out Item)
   is
      current_compilation_Unit :          AdaM.compilation_Unit.view;
      standard_Package         : constant AdaM.a_Package.view       := AdaM.a_Package.new_Package ("Standard");
   begin
      current_compilation_Unit := AdaM.compilation_Unit.new_compilation_Unit (Name => "Standard");
      Self.add (current_compilation_Unit);
      Self.standard_package_is (standard_Package);
      current_compilation_Unit.Entity_is (standard_Package.all'Access);

      add_pragma_Pure:
      declare
         new_Pragma : constant AdaM.a_Pragma.view
           := AdaM.a_Pragma.new_Pragma (Name => "Pure");
      begin
         new_Pragma.add_Argument ("Standard");

         standard_Package.Children.append (new_Pragma.all'Access);
      end add_pragma_Pure;


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
         new_integer_Type.First_is (Long_Long_Integer (Integer'First));
         new_integer_Type.Last_is  (Long_Long_Integer (Integer'Last));

         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_Integer;

      add_Natural:
      declare
         new_Subtype : constant AdaM.a_Type.a_subtype.view
           := AdaM.a_Type.a_subtype.new_Type (Name => "Natural");
      begin
         new_Subtype.main_Type_is (Self.find ("Integer"));
         new_Subtype.First_is ("0");
         new_Subtype.Last_is  ("Integer'Last");

         standard_Package.Children.append (new_Subtype.all'Access);
      end add_Natural;

      add_Positive:
      declare
         new_Subtype : constant AdaM.a_Type.a_subtype.view
           := AdaM.a_Type.a_subtype.new_Type (Name => "Positive");
      begin
         new_Subtype.main_Type_is (Self.find ("Integer"));
         new_Subtype.First_is ("1");
         new_Subtype.Last_is  ("Integer'Last");

         standard_Package.Children.append (new_Subtype.all'Access);
      end add_Positive;

      add_short_short_Integer:
      declare
         new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
           := AdaM.a_Type.signed_integer_type.new_Type (Name => "Short_Short_Integer");
      begin
         new_integer_Type.First_is (Long_Long_Integer (Short_Short_Integer'First));
         new_integer_Type.Last_is  (Long_Long_Integer (Short_Short_Integer'Last));

         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_short_short_Integer;

      add_short_Integer:
      declare
         new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
           := AdaM.a_Type.signed_integer_type.new_Type (Name => "Short_Integer");
      begin
         new_integer_Type.First_is (Long_Long_Integer (short_Integer'First));
         new_integer_Type.Last_is  (Long_Long_Integer (short_Integer'Last));

         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_short_Integer;

      add_long_Integer:
      declare
         new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
           := AdaM.a_Type.signed_integer_type.new_Type (Name => "Long_Integer");
      begin
         new_integer_Type.First_is (Long_Long_Integer (long_Integer'First));
         new_integer_Type.Last_is  (Long_Long_Integer (long_Integer'Last));

         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_long_Integer;

      add_long_long_Integer:
      declare
         new_integer_Type : constant AdaM.a_Type.signed_integer_type.view
           := AdaM.a_Type.signed_integer_type.new_Type (Name => "Long_Long_Integer");
      begin
         new_integer_Type.First_is (Long_Long_Integer'First);
         new_integer_Type.Last_is  (Long_Long_Integer'Last);

         standard_Package.Children.append (new_integer_Type.all'Access);
      end add_long_long_Integer;


      add_short_Float:
      declare
         new_float_Type : constant AdaM.a_Type.floating_point_type.view
           := AdaM.a_Type.floating_point_type.new_Type (Name => "Short_Float");
      begin
         new_float_Type.Digits_are (6);
         new_float_Type.First_is   (long_long_Float (Short_Float'First));
         new_float_Type.Last_is    (long_long_Float (Short_Float'Last));

         standard_Package.Children.append (new_float_Type.all'Access);
      end add_short_Float;

      add_Float:
      declare
         new_float_Type : constant AdaM.a_Type.floating_point_type.view
           := AdaM.a_Type.floating_point_type.new_Type (Name => "Float");
      begin
         new_float_Type.Digits_are (6);
         new_float_Type.First_is   (long_long_Float (Float'First));
         new_float_Type.Last_is    (long_long_Float (Float'Last));

         standard_Package.Children.append (new_float_Type.all'Access);
      end add_Float;

      add_long_Float:
      declare
         new_float_Type : constant AdaM.a_Type.floating_point_type.view
           := AdaM.a_Type.floating_point_type.new_Type (Name => "Long_Float");
      begin
         new_float_Type.Digits_are (15);
         new_float_Type.First_is   (long_long_Float (long_Float'First));
         new_float_Type.Last_is    (long_long_Float (long_Float'Last));

         standard_Package.Children.append (new_float_Type.all'Access);
      end add_long_Float;

      add_long_long_Float:
      declare
         new_float_Type : constant AdaM.a_Type.floating_point_type.view
           := AdaM.a_Type.floating_point_type.new_Type (Name => "Long_Long_Float");
      begin
         new_float_Type.Digits_are (18);
         new_float_Type.First_is   (long_long_Float'First);
         new_float_Type.Last_is    (long_long_Float'Last);

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
           := AdaM.a_Type.enumeration_type.new_Type (Name => "Wide_Character");
      begin
         standard_Package.Children.append (new_enum_Type.all'Access);
      end add_wide_Character;

      add_wide_wide_Character:
      declare
         new_enum_Type : constant AdaM.a_Type.enumeration_type.view
           := AdaM.a_Type.enumeration_type.new_Type (Name => "Wide_Wide_Character");
      begin
         standard_Package.Children.append (new_enum_Type.all'Access);
      end add_wide_wide_Character;

      add_String:
      declare
         new_array_Type : constant AdaM.a_Type.array_type.view
           := AdaM.a_Type.array_type.new_Type (Name => "String");

         new_Pragma     : constant AdaM.a_Pragma.view
           := AdaM.a_Pragma.new_Pragma (Name => "Pack");
      begin
         new_array_Type.  index_Type_is (Self.find ("Standard.Positive"));
         new_array_Type.element_Type_is (Self.find ("Standard.Character"));
         new_array_Type.is_Constrained  (Now => False);

         new_Pragma.add_Argument ("String");

         standard_Package.Children.append (new_array_Type.all'Access);
         standard_Package.Children.append (new_Pragma.all'Access);
      end add_String;

      add_wide_String:
      declare
         new_array_Type : constant AdaM.a_Type.array_type.view
           := AdaM.a_Type.array_type.new_Type (Name => "Wide_String");

         new_Pragma     : constant AdaM.a_Pragma.view
           := AdaM.a_Pragma.new_Pragma (Name => "Pack");
      begin
         new_array_Type.  index_Type_is (Self.find ("Standard.Positive"));
         new_array_Type.element_Type_is (Self.find ("Standard.Wide_Character"));
         new_array_Type.is_Constrained  (Now => False);

         new_Pragma.add_Argument ("Wide_String");

         standard_Package.Children.append (new_array_Type.all'Access);
         standard_Package.Children.append (new_Pragma.all'Access);
      end add_wide_String;

      add_wide_wide_String:
      declare
         new_array_Type : constant AdaM.a_Type.array_type.view
           := AdaM.a_Type.array_type.new_Type (Name => "Wide_Wide_String");

         new_Pragma     : constant AdaM.a_Pragma.view
           := AdaM.a_Pragma.new_Pragma (Name => "Pack");
      begin
         new_array_Type.  index_Type_is (Self.find ("Standard.Positive"));
         new_array_Type.element_Type_is (Self.find ("Standard.Wide_Wide_Character"));
         new_array_Type.is_Constrained  (Now => False);

         standard_Package.Children.append (new_array_Type.all'Access);
         standard_Package.Children.append (new_Pragma.all'Access);

         new_Pragma.add_Argument ("Wide_Wide_String");
      end add_wide_wide_String;

      add_Duration:
      declare
         use Ada.Strings,
             Ada.Strings.fixed;

         new_ordinary_fixed_Type : constant AdaM.a_Type.ordinary_fixed_point_type.view
           := AdaM.a_Type.ordinary_fixed_point_type.new_Type (Name => "Duration");
      begin
         new_ordinary_fixed_Type.Delta_is (Trim (Duration'Image (Duration'Delta), Left));
         new_ordinary_fixed_Type.First_is ("-((2 ** 63)     * 0.000000001)");
         new_ordinary_fixed_Type.Last_is  ("+((2 ** 63 - 1) * 0.000000001)");

         standard_Package.Children.append (new_ordinary_fixed_Type.all'Access);
      end add_Duration;

      add_constraint_Error:
      declare
         new_Exception : constant AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("Constraint_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_constraint_Error;

      add_program_Error:
      declare
         new_Exception : constant AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("Program_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_program_Error;

      add_storage_Error:
      declare
         new_Exception : constant AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("Storage_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_storage_Error;

      add_tasking_Error:
      declare
         new_Exception : constant AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("Tasking_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_tasking_Error;

      add_numeric_Error:   -- TODO: Make this a proper exception renaming as per 'standard.ads'.
      declare
         new_Exception : constant AdaM.Declaration.of_exception.view
           := Adam.Declaration.of_exception.new_Declaration ("Numeric_Error");
      begin
         standard_Package.Children.append (new_Exception.all'Access);
      end add_numeric_Error;

   end add_package_Standard;


end AdaM.Environment;
