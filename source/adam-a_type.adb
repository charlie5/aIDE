with
     adam.Factory,
     ada.Tags;


package body adam.a_Type
is

   -- Forge
   --

   procedure destruct (Self : in out Item)
   is
   begin
      raise Program_Error with "'adam.a_Type' subclasses must override the 'destruct' procedure";
   end destruct;




   --  Attributes
   --

   overriding
   function Name (Self : in Item) return String
   is
   begin
      return +Self.Name;
   end Name;


   procedure Name_is   (Self : in out Item;   Now : in String)
   is
   begin
      Self.Name := +Now;
   end Name_is;




   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
   is
      use Ada.Tags;
   begin
      if Self = null
      then
         adam.Id'write  (Stream,  null_Id);
         return;
      end if;

      adam.Id'write  (Stream,  Self.Id);
      String 'output (Stream,  external_Tag (Self.all'Tag));
   end View_write;



   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
   is
      Id : adam.Id;
   begin
      adam.Id'read (Stream, Id);

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
         Self := View (adam.Factory.to_View (Id, the_Tag));
      end;
   end View_read;


end adam.a_Type;