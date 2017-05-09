with
     ada.Streams,
     ada.Containers.Vectors;


package AdaM.a_Type.enumeration_literal
is

   type Item is new AdaM.a_Type.discrete_Type with private;


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



   --  Forge
   --

   function  new_Literal (Value : in     String := "") return enumeration_literal.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out enumeration_literal.view);


   --  Attributes
   --

   overriding
   function  Id    (Self : access Item) return AdaM.Id;

   overriding
   function  to_spec_Source   (Self : in Item) return text_Vectors.Vector;



private

   type Item is new AdaM.a_Type.discrete_Type with
      record
         null;
         -- Value : Text;
      end record;

end AdaM.a_Type.enumeration_literal;
