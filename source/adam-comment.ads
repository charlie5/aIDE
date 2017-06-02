with
--       AdaM.Source,
     AdaM.Entity;

private
with
     ada.Streams;


package AdaM.Comment
is

--     type Item is new Source.Entity with private;
   type Item is new Entity.item with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Comment         return Comment.view;
   procedure free        (Self : in out Comment.view);
   procedure destruct    (Self : in out Item);



   --  Attributes
   --

   overriding
   function Id         (Self : access Item) return AdaM.Id;

   function  Lines     (Self : in     Item)     return text_Lines;
   procedure Lines_are (Self : in out Item;   Now : in text_Lines);

   overriding
   function to_Source (Self : in     Item) return text_Vectors.Vector;

   overriding
   function  Name      (Self : in     Item) return String;


private

--     type Item is new Source.Entity with
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

end AdaM.Comment;
