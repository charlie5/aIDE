with
     AdaM.Any,
     AdaM.context_Line;

private
with
     ada.Streams;


package AdaM.Context
is

   type Item is new Any.Item with private;
   type View is access all Item'Class;



   --  Forge
   --

   function  new_Context (Name : in     String := "") return Context.view;
   procedure free        (Self : in out View);
   procedure destruct    (Self : in out Item);



   --  Attributes
   --

   overriding
   function  Id        (Self : access Item) return AdaM.Id;
   function  Lines     (Self : in     Item) return context_Line.vector;

   procedure add       (Self : in out Item;   the_Line : in context_Line.view);
   procedure rid       (Self : in out Item;   the_Line : in context_Line.view);

   function  to_Source (Self : in     Item) return text_Vectors.vector;



private

   type Item is new Any.Item with
      record
         Lines : context_Line.vector;
      end record;


   -- Streams
   --
   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.Context;
