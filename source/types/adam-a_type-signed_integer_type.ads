with
     Ada.Streams;


package AdaM.a_Type.signed_integer_type
is

   type Item is new a_Type.integer_Type with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Type (Name : in     String := "") return signed_integer_type.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out signed_integer_type.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return AdaM.Id;

   overriding
   function  to_Source   (Self : in Item) return text_Vectors.Vector;

   function  First    (Self : in     Item)     return Long_Long_Integer;
   procedure First_is (Self : in out Item;   Now : in Long_Long_Integer);

   function  Last    (Self : in     Item)     return Long_Long_Integer;
   procedure Last_is (Self : in out Item;   Now : in Long_Long_Integer);



private

   type Item is new a_Type.integer_Type with
      record
         First : Long_Long_Integer := 0;
         Last  : Long_Long_Integer := Long_Long_Integer'Last;
      end record;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.a_Type.signed_integer_type;
