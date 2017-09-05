with
     Ada.Streams;


package AdaM.a_Type.floating_point_type
is

   type Item is new a_Type.real_Type with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Type (Name : in     String := "") return floating_point_type.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out floating_point_type.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return AdaM.Id;


   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector;


   function  my_Digits  (Self : in     Item)     return Positive;
   procedure Digits_are (Self : in out Item;   Now : in Positive);

   function  First    (Self : in     Item)     return long_long_Float;
   procedure First_is (Self : in out Item;   Now : in long_long_Float);

   function  Last    (Self : in     Item)     return long_long_Float;
   procedure Last_is (Self : in out Item;   Now : in long_long_Float);


private

   type Item is new a_Type.real_Type with
      record
         my_Digits : Positive := 1;
         First     : long_long_Float;
         Last      : long_long_Float;
      end record;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.a_Type.floating_point_type;
