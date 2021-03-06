with
     AdaM.Factory,
     AdaM.Entity;

with Ada.Text_IO; use Ada.Text_IO;


package body AdaM.Declaration.of_package
is

   --  Storage Pool
   --

   record_Version : constant := 1;
   max_Packages   : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "packages",
                                           max_Packages,
                                           record_Version,
                                           Declaration.of_package.item,
                                           Declaration.of_package.view);

   --  Forge
   --

   procedure define (Self : in out Item;   Name : in Identifier)
   is
   begin
      Self.Name    := +(+Name);
      Self.Context := AdaM.Context.new_Context ("");
   end define;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Package (Name : in Identifier := "") return View
   is
      new_View : constant Declaration.of_package.view := Pool.new_Item;
   begin
      define (Declaration.of_package.item (new_View.all), Name);
      return new_View;
   end new_Package;



   procedure free (Self : in out Declaration.of_package.view)
   is
   begin
      destruct (Declaration.of_package.item (Self.all));
      Pool.free (Self);
   end free;




   --  Attributes
   --

   overriding
   function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;



--     function Name (Self : in Item) return String
--     is
--     begin
--        return +Self.Name;
--     end Name;
--
--
--     procedure Name_is (Self : in out Item;   Now : in String)
--     is
--     begin
--        Self.Name := +Now;
--     end Name_is;



   function Context (Self : in     Item) return AdaM.Context.view
   is
   begin
      return Self.Context;
   end Context;



--     procedure add (Self : in out Item;   the_Declaration : in Source.Entity_View)
--     is
--     begin
--        Self.public_Entities.append (the_Declaration);     -- Add the new attribute to current attributes.
--     end add;
--
--
--     procedure rid (Self : in out Item;   the_Declaration : in Source.Entity_View)
--     is
--     begin
--        Self.public_Entities.delete (Self.public_Entities.find_Index (the_Declaration));     -- Remove the old attribute from current attributes.
--     end rid;
--
--
--
--
--     function  public_Entities (Self : access     Item) return access Source.Entities
--     is
--     begin
--        return Self.public_Entities'Access;
--     end public_Entities;
--
--
--     procedure public_Entities_are (Self : in out Item;   Now : in Source.Entities)
--     is
--     begin
--        Self.public_Entities := Now;
--     end public_Entities_are;
--


--     function all_Exceptions (Self : in     Item) return AdaM.Declaration.of_exception.Vector
--     is
--        use type Declaration.of_exception.view;
--
--        the_Exceptions : AdaM.Declaration.of_exception.Vector;
--        the_Exception  : AdaM.Declaration.of_exception.view;
--     begin
--        put_Line ("PACKAGE NAME: " & (+Self.Name));
--
--        for Each of Self.public_Entities
--        loop
--           put_Line ("*************   Tag: " & ada.Tags.External_Tag (Each.all'Tag));
--              raise program_Error with "sdfhslkad";
--
--           the_Exception := Declaration.of_exception.view (Each);
--
--           if the_Exception /= null
--  --           if Each in AdaM.an_Exception.item'Class
--           then
--              the_Exceptions.append (the_Exception);
--           end if;
--        end loop;
--
--        return the_Exceptions;
--     end all_Exceptions;


   function all_Exceptions (Self : access     Item) return AdaM.Declaration.of_exception.Vector
   is
      use type Declaration.of_exception.view;

      the_Exceptions : AdaM.Declaration.of_exception.Vector;
--        the_Exception  : AdaM.Declaration.of_exception.view;
   begin
--        put_Line ("all_Exceptions PACKAGE NAME: " & (+Self.Name));

      for Each of Self.Children.all
      loop
--           put_Line ("*************   Tag: " & ada.Tags.External_Tag (Each.all'Tag));
--              raise program_Error with "sdfhslkad";

--           the_Exception := Declaration.of_exception.view (Each);

--           if the_Exception /= null
         if Each.all in AdaM.Declaration.of_Exception.item'Class
         then
            the_Exceptions.append (Declaration.of_exception.view (Each));
         end if;
      end loop;

      return the_Exceptions;
   end all_Exceptions;




   function all_Types (Self : access Item) return AdaM.a_Type.Vector
   is
      use type a_Type.view;

      the_Exceptions : AdaM.a_Type.Vector;
--        the_Exception  : AdaM.Declaration.of_exception.view;
   begin
--        put_Line ("all_Exceptions PACKAGE NAME: " & (+Self.Name));

      for Each of Self.Children.all
      loop
--           put_Line ("*************   Tag: " & ada.Tags.External_Tag (Each.all'Tag));
--              raise program_Error with "sdfhslkad";

--           the_Exception := Declaration.of_exception.view (Each);

--           if the_Exception /= null
         if Each.all in AdaM.a_Type.item'Class
         then
            the_Exceptions.append (a_Type.view (Each));
         end if;
      end loop;

      return the_Exceptions;
   end all_Types;







   overriding
   function to_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.unbounded;

      the_Source : text_Vectors.Vector;

      procedure add (the_Line : in Text)
      is
      begin
         the_Source.append (the_Line);
      end add;

   begin
      the_Source.append (Self.Context.to_Source);

      add (+"");
      add ( "package " & Self.Name);
      add (+"is");

      add (+"");

--        the_Source.append (Self.public_Entities.to_spec_Source);

      add (+"");
      add ( "end " & Self.Name & ";");

      return the_Source;
   end to_Source;



   function to_spec_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.unbounded;

      the_Source : text_Vectors.Vector;

      procedure add (the_Line : in Text)
      is
      begin
         the_Source.append (the_Line);
      end add;

   begin
      the_Source.append (Self.Context.to_Source);

      add (+"");
      add ( "package " & Self.Name);
      add (+"is");

      add (+"");

--        the_Source.append (Self.public_Entities.to_spec_Source);

      add (+"");
      add ( "end " & Self.Name & ";");

      return the_Source;
   end to_spec_Source;



   function to_body_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.unbounded;

      the_Source : text_Vectors.Vector;

      procedure add (the_Line : in Text)
      is
      begin
         the_Source.append (the_Line);
      end add;

   begin
      the_Source.append (Self.Context.to_Source);

      add (+"");
      add ( "package body " & Self.Name);
      add (+"is");

      add (+"");

--        the_Source.append (Self.public_Entities.to_body_Source);

      add (+"");
      add ( "end " & Self.Name & ";");

      return the_Source;
   end to_body_Source;



   function requires_Body (Self : in Item) return Boolean
   is
      pragma Unreferenced (Self);
--        use AdaM.Source.utility;
   begin
      return False; -- contains_Subprograms (Self.public_Entities);
   end requires_Body;



   procedure Parent_is (Self : in out Item;   Now : in Declaration.of_package.View)
   is
   begin
      Self.Parent := Now;
   end Parent_is;



   function  Parent    (Self : in Item) return Declaration.of_package.view
   is
   begin
      return Self.Parent;
   end Parent;




   function  child_Packages (Self : in Item'Class) return Declaration.of_package.Vector
   is
   begin
      return Self.child_Packages;
   end child_Packages;


   function  child_Package   (Self : in     Item'Class;   Named : in String) return Declaration.of_package.view
   is
   begin
      for Each of Self.child_Packages
      loop
         if Each.Name = Named
         then
            return Each;
         end if;
      end loop;

      return null;
   end child_Package;



   procedure add_Child (Self : in out Item;   Child : in Declaration.of_package.View)
   is
   begin
      Self.child_Packages.append (Child);
   end add_Child;



   function  find (Self : in Item;   Named : in Identifier) return AdaM.a_Type.view
   is
   begin
      for Each of Self.Children.all
      loop
--           put_Line ("--- find type in package " & (+Self.Name) & "   ---    Tag => " & ada.Tags.External_Tag (Each.all'Tag));

         if Each.all in AdaM.a_Type.item'Class
         then
            if Each.Name = Named
            then
               return AdaM.a_Type.view (Each);
            end if;
         end if;
      end loop;

      put_Line (String (Named) & " NOT FOUND in package " & (+Self.Name));
      return null;
   end find;



   function  find (Self : in Item;   Named : in Identifier) return AdaM.Declaration.of_exception.view
   is
   begin
      for Each of Self.Children.all
      loop
--           put_Line ("--- find type in package " & (+Self.Name) & "   ---    Tag => " & ada.Tags.External_Tag (Each.all'Tag));

         if Each.all in AdaM.Declaration.of_exception.item'Class
         then
            if Each.Name = Named
            then
               return AdaM.Declaration.of_exception.view (Each);
            end if;
         end if;
      end loop;

      put_Line (String (Named) & " NOT FOUND in package " & (+Self.Name));
      return null;
   end find;




   function  full_Name  (Self : in Item) return Identifier
   is
   begin
      if Self.Parent = null   -- Is the Standard package.
      then
         return "Standard";
      end if;

      if Self.Parent.Name = "Standard"
      then
         return +Self.Name;
      else
         return Self.Parent.full_Name & "." & (+Self.Name);
      end if;
   end full_Name;



   -- Streams
   --

   procedure Item_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              Item)
   is
   begin
      Text'write (Stream, Self.Name);

      Declaration.of_package.view  'write (Stream, Self.Parent);
      Declaration.of_package.Vector'write (Stream, Self.Progenitors);
      Declaration.of_package.Vector'write (Stream, Self.child_Packages);

      AdaM.Context.view'write (Stream, Self.Context);
--        Source.Entities  'write (Stream, Self.public_Entities);

      Entity.view    'write (Stream, Self.parent_Entity);
      Entity.Entities'write (Stream, Self.Children);
   end Item_write;



   procedure Item_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             Item)
   is
      Version : constant Positive := Pool.storage_record_Version;
   begin
      case Version
      is
      when 1 =>
         Text'read (Stream, Self.Name);
--           put_Line ("KKKKKKKKKKKKKK '" & (+Self.Name) & "'");

         Declaration.of_package.view  'read (Stream, Self.Parent);
         Declaration.of_package.Vector'read (Stream, Self.Progenitors);
         Declaration.of_package.Vector'read (Stream, Self.child_Packages);

         AdaM.Context.view'read (Stream, Self.Context);
--           Source.Entities  'read (Stream, Self.public_Entities);

         declare
            Parent : Declaration.of_package.view;
         begin
            Declaration.of_package.view'read (Stream, Parent);

            if Parent /= null
            then
--                 program_Unit.item (Self).parent_Entity_is (Parent.all'Access);
               Self.parent_Entity_is (Parent.all'Access);
            end if;
         end;

         declare
            Children : Entity.Entities;
         begin
            Entity.Entities'read (Stream, Children);
--              program_Unit.item (Self).Children_are (Children);
            Self.Children_are (Children);
         end;

      when others =>
         raise Program_Error with "Illegal version number during package restore.";
      end case;
   end Item_read;


   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.Declaration.of_package;
