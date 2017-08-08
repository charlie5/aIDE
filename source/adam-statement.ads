with
     AdaM.Entity;

private
with
     ada.Streams;


package AdaM.Statement
is

   type Item is new Entity.item with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Statement (Line : in     String := "") return Statement.view;
   procedure free          (Self : in out Statement.view);

   procedure destruct      (Self : in out Item);


   --  Attributes
   --

   overriding
   function Id        (Self : access Item) return AdaM.Id;

   overriding
   function Name      (Self : in     Item) return String;

   overriding
   function to_Source (Self : in     Item) return text_Vectors.Vector;

   procedure add      (Self : in out Item;   the_Line : in String);



private

   type Item is new Entity.item with
      record
         Lines : Text_vectors.Vector;
      end record;


   -- Streams
   --
   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.Statement;
