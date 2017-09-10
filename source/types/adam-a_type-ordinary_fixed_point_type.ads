with
     Ada.Streams;


package AdaM.a_Type.ordinary_fixed_point_type
is

   type Item is new a_Type.fixed_Type with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Type (Name : in     String := "") return ordinary_fixed_point_type.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out ordinary_fixed_point_type.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return AdaM.Id;


   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector;


   function  my_Delta (Self : in     Item)     return String;
   procedure Delta_is (Self : in out Item;   Now : in String);

   function  First    (Self : in     Item)     return String;
   procedure First_is (Self : in out Item;   Now : in String);

   function  Last    (Self : in     Item)     return String;
   procedure Last_is (Self : in out Item;   Now : in String);



private

   type Item is new a_Type.fixed_Type with
      record
         my_Delta  : Text;
         First     : Text;
         Last      : Text;
      end record;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.a_Type.ordinary_fixed_point_type;
