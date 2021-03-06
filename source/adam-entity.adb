with
     Ada.Tags,
     AdaM.Factory;


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

--     function Name (Self : in Item) return String
--     is
--        pragma Unreferenced (Self);
--     begin
--        return "<anon>";
--     end Name;



--     function full_Name (Self : in Item'Class) return String
--     is
--     begin
--        if Self.parent_Entity = null
--        then
--           return Self.Name;
--        else
--           return Self.parent_Entity.full_Name & "." & Self.Name;
--        end if;
--     end full_Name;




--     function to_spec_Source (Self : in Item) return text_Vectors.Vector
--     is
--        pragma Unreferenced (Self);
--        the_Source : text_Vectors.Vector;
--     begin
--        raise Program_Error with "TODO";
--        return the_Source;
--     end to_spec_Source;



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
      Self.Children := Entities (Now);
   end Children_are;



   function  is_Public (Self : in     Item)     return Boolean
   is
   begin
      return Self.is_Public;
   end is_Public;


   procedure is_Public (Self : in out Item;   Now : in Boolean := True)
   is
   begin
      Self.is_Public := Now;
   end is_Public;




   ----------
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
