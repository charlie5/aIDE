with
     Ada.Streams,
     Ada.Tags,
     AdaM.Factory;
with Ada.Text_IO; use Ada.Text_IO;

package body AdaM.Entity
is

   --  Entities
   --

   function to_spec_Source (the_Entities : in Entities) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      for Each of the_Entities
      loop
         the_Source.append (Each.to_Source);
      end loop;

      return the_Source;
   end to_spec_Source;



   -- Entity
   --

--     procedure add_Child (Self : in out Entity;   Child : in Entity_View)
--     is
--     begin
--        Self.Children.append (Child);
--     end add_Child;
--
--
--     procedure rid_Child (Self : in out Entity;   Child : in Entity_View)
--     is
--     begin
--        Self.Children.delete (Self.Children.find_Index (Child));
--     end rid_Child;



--     function Name (Self : in Item) return String
--     is
--        pragma Unreferenced (Self);
--     begin
--        return "<anon>";
--     end Name;



   function to_spec_Source (Self : in Item) return text_Vectors.Vector
   is
      pragma Unreferenced (Self);
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_spec_Source;



--     overriding
--     function Id (Self : access Entity) return AdaM.Id
--     is
--        pragma Unreferenced (Self);
--     begin
--        raise Program_Error with "Source.Entity Id must be overridden";
--        return AdaM.Id'Last;
--     end Id;







--     package body make_Entity
--     is
--
--        overriding
--        function  parent_Entity    (Self : in     Item)       return Entity.view
--        is
--        begin
--           return Self.parent_Entity;
--        end parent_Entity;
--
--
--        overriding
--        procedure parent_Entity_is (Self : in out Item;   Now : in Entity.View)
--        is
--        begin
--           Self.parent_Entity := Now;
--        end parent_Entity_is;
--
--
--        overriding
--        function  Children  (Self : access Item)     return Entities_view
--        is
--        begin
--           return Self.Children'Access;
--        end Children;
--
--
--        overriding
--        function  Children  (Self : in    Item)     return Entities'Class
--        is
--        begin
--           return Self.Children;
--        end Children;
--
--
--        overriding
--        procedure Children_are (Self : in out Item;   Now : in Entities'Class)
--        is
--        begin
--           put_Line ("AAAAAAAAAAAAAAAAAA " & ada.Tags.External_Tag (Now'Tag));
--           Self.Children := Entities (Now);
--        end Children_are;
--
--
--
--        -- Streams
--        --
--
--  --        procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--  --                              Self   : in              View)
--  --        is
--  --           use Ada.Tags;
--  --        begin
--  --           if Self = null
--  --           then
--  --              AdaM.Id'write  (Stream,  null_Id);
--  --              return;
--  --           end if;
--  --
--  --           AdaM.Id'write  (Stream,  Self.Id);
--  --           String 'output (Stream,  external_Tag (Self.all'Tag));
--  --        end View_write;
--  --
--  --
--  --
--  --        procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--  --                             Self   : out             View)
--  --        is
--  --           Id : AdaM.Id;
--  --        begin
--  --           AdaM.Id'read (Stream, Id);
--  --
--  --           if Id = null_Id
--  --           then
--  --              Self := null;
--  --              return;
--  --           end if;
--  --
--  --           declare
--  --              use Ada.Tags;
--  --              the_String : constant String  := String'Input   (Stream);                  -- Read tag as string from stream.
--  --              the_Tag    : constant Tag     := Descendant_Tag (the_String, Item'Tag);    -- Convert to a tag.
--  --           begin
--  --              Self := View (AdaM.Factory.to_View (Id, the_Tag));
--  --           end;
--  --        end View_read;
--
--
--
--     end make_Entity;




   function  parent_Entity    (Self : in     Item)       return Entity.view
   is
   begin
      return Self.parent_Entity;
   end parent_Entity;


   procedure parent_Entity_is (Self : in out Item;   Now : in Entity.View)
   is
   begin
      Self.parent_Entity := Now;
   end parent_Entity_is;


   function  Children  (Self : access Item)     return Entities_view
   is
   begin
      return Self.Children'unchecked_Access;
   end Children;


   function  Children  (Self : in    Item)     return Entities'Class
   is
   begin
      return Self.Children;
   end Children;


   procedure Children_are (Self : in out Item;   Now : in Entities'Class)
   is
   begin
      put_Line ("AAAAAAAAAAAAAAAAAA " & ada.Tags.External_Tag (Now'Tag));
      Self.Children := Entities (Now);
   end Children_are;







   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
   is
      use Ada.Tags;
   begin
      if Self = null
      then
         AdaM.Id'write  (Stream,  null_Id);
         return;
      end if;

      AdaM.Id'write  (Stream,  Self.Id);
      String 'output (Stream,  external_Tag (Self.all'Tag));
   end View_write;



   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
   is
      Id : AdaM.Id;
   begin
      AdaM.Id'read (Stream, Id);

      if Id = null_Id
      then
         Self := null;
         return;
      end if;

      declare
         use Ada.Tags;
         the_String : constant String  := String'Input   (Stream);                  -- Read tag as string from stream.
         the_Tag    : constant Tag     := Descendant_Tag (the_String, Item'Tag);    -- Convert to a tag.
      begin
         Self := View (AdaM.Factory.to_View (Id, the_Tag));
      end;
   end View_read;



end AdaM.Entity;
