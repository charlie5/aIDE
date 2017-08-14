with
     AdaM.Entity,
     Ada.Streams;


package AdaM.raw_source
is

   type Item is new Entity.item with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Source         return raw_Source.view;
   procedure free       (Self : in out raw_Source.view);
   procedure destruct   (Self : in out Item);



   --  Attributes
   --

   function  Lines     (Self : in     Item)     return text_Lines;
   procedure Lines_are (Self : in out Item;   Now : in text_Lines);


   overriding
   function Id (Self : access Item) return AdaM.Id;

   overriding
   function to_Source (Self : in     Item) return text_Vectors.Vector;

   overriding
   function  Name      (Self : in     Item) return Identifier;


private

   type Item is new Entity.item with
      record
         Lines : text_Lines;
      end record;


   -- Streams
   --
   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);
   procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.raw_source;
