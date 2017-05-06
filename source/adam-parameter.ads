with
     adam.Any,
     adam.a_Type,

     ada.Streams;


package adam.Parameter
is

   type Item is new Any.Item with private;


   -- View
   --
   type View is access all Item'Class;

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;


   --  Vector
   --
   package Vectors is new ada.Containers.Vectors (Positive, View);
   subtype Vector  is     Vectors.Vector;

   function  to_Source (the_Parameters : in     Vector) return text_Vectors.Vector;


   --  Types
   --

   type a_Mode is (in_Mode, out_Mode, in_out_Mode, access_Mode);


   --  Forge
   --

   function  new_Parameter (Name : in     String := "") return Parameter.view;
   procedure free      (Self : in out Parameter.view);

   procedure destruct  (Self : in out Item);


   --  Attributes
   --

   overriding function  Id         (Self : access Item) return adam.Id;

   function  Name       (Self : in     Item)     return String;
   procedure Name_is    (Self : in out Item;   Now : in String);

   function  Mode       (Self : in     Item)     return a_Mode;
   procedure Mode_is    (Self : in out Item;   Now : in a_Mode);

   function  my_Type    (Self : access Item) return access a_Type.view;
   function  my_Type    (Self : in     Item)     return a_Type.view;
   procedure Type_is    (Self : in out Item;   Now : in a_Type.view);

   function  Default    (Self : in     Item)     return String;
   procedure Default_is (Self : in out Item;   Now : in String);

   function  to_Source  (Self : in     Item) return text_Vectors.Vector;



private

   type Item is new Any.Item with
      record
         Name         :         Text;
         Mode         :         a_Mode;
         my_Type      : aliased a_Type.view;
         Default      :         Text;
      end record;

end adam.Parameter;
