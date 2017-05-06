with
     ada.Streams;


package adam.a_Type.constrained_array_type
is

   type Item is new a_Type.composite_Type with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Type (Name : in     String := "") return constrained_array_type.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out constrained_array_type.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return adam.Id;



private

   type Item is new a_Type.composite_Type with
      record
         null;
      end record;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end adam.a_Type.constrained_array_type;