with
     AdaM.Source,

     ada.Text_IO,
     ada.Tags,
     ada.Strings.fixed;
with AdaM.Entity;


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
      the_Entity : AdaM.Source.Entity_View;

      use type AdaM.a_Type.view;
   begin
      for i in 1 .. Self.Length
      loop
         the_Unit := Self.Units.Element (i);

         for j in 1 .. the_Unit.Length
         loop
            the_Entity := the_Unit.Entity (j);

            if the_Entity.all in AdaM.a_Type.item'Class
            then
               the_Types.append (AdaM.a_Type.view (the_Entity));
            end if;
         end loop;
      end loop;

      return the_Types;
   end all_Types;



   procedure print (Self : in Item)
   is
      use AdaM.Source,
          ada.Strings.fixed,
          ada.Text_IO;
      the_Unit   : AdaM.compilation_Unit.view;
      the_Entity : AdaM.Source.Entity_View;

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

         for i in 1 .. the_Unit.Length
         loop
            the_Entity := the_Unit.Entity (i);

            Depth := Depth + 1;
--              ada.Text_IO.put_Line (Indent & "Entity : " & the_Entity.Name & "   Tag = " & ada.Tags.Expanded_Name (the_Entity.all'Tag));
            Depth := Depth - 1;
         end loop;
      end loop;

      new_Line;
      put_Line ("End Environment:");
   end print;



   procedure print_Entities (Self : in Item)
   is
      use AdaM.Source,
          ada.Strings.fixed,
          ada.Text_IO;

      the_Unit   : AdaM.compilation_Unit.view;
      the_Entity : AdaM.Entity.view;

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
         the_Unit   := Self.Unit (i);
         the_Entity := the_Unit.Entity;

         New_Line (2);
         put_Line ("Unit.Name = " & the_Unit.Name);
         put_Line ("Entity.Name = " & the_Entity.Name);

         for Each of the_Entity.Children.all
         loop
            put_Line ("Child.Name = " & Each.Name);
         end loop;
      end loop;

      new_Line;
      put_Line ("End Environment:");
   end print_Entities;


end AdaM.Environment;
