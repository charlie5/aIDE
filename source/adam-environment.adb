with
--       AdaM.Source,

     ada.Text_IO,
     ada.Tags,
     ada.Strings.fixed;
with AdaM.Entity;

use ada.Text_IO;


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
      use type AdaM.a_Package.view;
   begin
      if Now = null
      then
         raise program_Error with "sdfkgasdjkfgslkadgf";
      end if;

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



   function parent_Name (Identifier : in String) return String
   is
      use Ada.Strings,
          Ada.Strings.fixed;
      I : constant Natural := Index (Identifier, ".", going => Backward);
   begin
      if I = 0
      then
         return "Standard";
      end if;

      return Identifier (Identifier'First .. I - 1);
   end parent_Name;



   function simple_Name (Identifier : in String) return String
   is
      use Ada.Strings,
          Ada.Strings.fixed;
      I : constant Natural := Index (Identifier, ".", going => Backward);
   begin
      if I = 0
      then
         return Identifier;
      end if;

      return Identifier (I + 1 .. Identifier'Last);
   end simple_Name;



   function Split (Identifier : in String) return text_Lines
   is
      use Ada.Strings,
          Ada.Strings.fixed;

      First : Natural := Identifier'First;
      Last  : Natural;

      I     : Natural;
      Lines : text_Lines;
   begin
      loop
         I := Index (Identifier, ".", from => First);

         if I = 0
         then
            Last := Identifier'Last;
            Lines.append (+Identifier (First .. Last));
            exit;
         end if;

         Last  := I - 1;
         Lines.append (+Identifier (First .. Last));
         First := I + 1;
      end loop;

      return Lines;
   end Split;



   function  find (Self : in Item;   Identifier : in String) return AdaM.a_Package.view
   is
      the_Package : AdaM.a_Package.view := Self.standard_Package;
   begin
      put_Line (Integer'Image (Integer (Self.Units.Length)));
      put_Line ("the_Package.full_Name) = " & the_Package.full_Name);

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
      else
         put_Line ("STANDARD");
      end if;

      return the_Package;
   end find;



   function  fetch (Self : in Item;   Identifier : in String) return AdaM.a_Package.view
   is
      use type AdaM.a_Package.view;

      the_Package : AdaM.a_Package.view := Self.standard_Package;
      Parent      : AdaM.a_Package.view;
      Names       : constant text_Lines := Split (Identifier);
   begin
      put_Line ("JJJJJJJJJ " & Identifier);

      if Identifier = "Standard"
      then
         return the_Package;
      end if;

      for Each of Names
      loop
         put_Line ("KKKKKKKKKKK " & (+Each));

         Parent      := the_Package;
         the_Package := the_Package.child_Package (+Each);

         if the_Package = null
         then
            -- Create a new package."
            --
            the_Package := AdaM.a_Package.new_Package (Parent.Name & "." & (+Each));
            the_Package.Parent_is (Parent);
            Parent.add_Child (the_Package);
         end if;
      end loop;

      return the_Package;
   end fetch;



   function  find (Self : in Item;   Identifier : in String) return AdaM.a_Type.view
   is
      the_Package : constant AdaM.a_Package.view := Self.find (parent_Name (Identifier));
   begin
      return the_Package.find (simple_Name (Identifier));
   end find;



   function  find  (Self : in Item;   Identifier : in String) return AdaM.Declaration.of_exception.view
   is
      the_Package : constant AdaM.a_Package.view := Self.find (parent_Name (Identifier));
   begin
      put_Line ("ZZZZZZZZZZZZZZZZZZZZZZ parent_Name (Identifier) = '" & parent_Name (Identifier) & "'");
      return the_Package.find (simple_Name (Identifier));
   end find;



   procedure print (Self : in Item)
   is
      use -- AdaM.Source,
          ada.Strings.fixed,
          ada.Text_IO;
      the_Unit   : AdaM.compilation_Unit.view;
--        the_Entity : AdaM.Source.Entity_View;

      Depth      : Natural := 0;

      function Indent return String
      is
      begin
         return Depth * "   ";
      end Indent;

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
      use -- AdaM.Source,
          ada.Strings.fixed,
          ada.Text_IO;

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
--           put_Line ("Entity.Name = " & the_Entity.Name & "     of kind " & );

         Depth := Depth + 1;
         put_Line (Indent
                   & "Entity.Name : "             & the_Entity.Name
                   & "                    Tag = " & ada.Tags.Expanded_Name (the_Entity.all'Tag));
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
         put_Line ("Top Entity.Name = " & top_Entity.Name);

         print (top_Entity);
      end loop;

      new_Line;
      put_Line ("End Environment:");
   end print_Entities;


end AdaM.Environment;
