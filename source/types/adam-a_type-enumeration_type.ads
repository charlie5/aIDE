with
     adam.a_Type.enumeration_literal,
     ada.Streams;


package adam.a_Type.enumeration_type
is

   type Item is new a_Type.discrete_Type with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Type (Name : in     String := "") return enumeration_type.view;
   procedure free     (Self : in out enumeration_type.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return adam.Id;

   function  Literals     (Self : in     Item)     return enumeration_literal.Vector;
   procedure Literals_are (Self : in out Item;   Now : in enumeration_literal.Vector);

   procedure add_Literal (Self : in out Item;   Value : in String);
   procedure rid_Literal (Self : in out Item;   Value : in String);


   overriding
   function  to_spec_Source   (Self : in Item) return text_Vectors.Vector;


private

   type Item is new a_Type.discrete_Type with
      record
         Literals : aliased enumeration_literal.Vector;
      end record;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end adam.a_Type.enumeration_type;
