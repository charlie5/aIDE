with
     AdaM.subtype_Indication,
     Ada.Streams;


package AdaM.a_Type.a_subtype
is

   type Item is new a_Type.item with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Subtype (Name : in     String := "") return a_subtype.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out a_subtype.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return AdaM.Id;


   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector;


   function  Indication (Self : in    Item)        return AdaM.subtype_Indication.view;

--     function  main_Type    (Self : access Item)     return access AdaM.a_Type.view;
--     function  main_Type    (Self : in     Item)     return AdaM.a_Type.view;
--     procedure main_Type_is (Self : in out Item;   Now : in AdaM.a_Type.view);
--
--
--     function  First    (Self : in     Item)     return String;
--     procedure First_is (Self : in out Item;   Now : in String);
--
--     function  Last    (Self : in     Item)     return String;
--     procedure Last_is (Self : in out Item;   Now : in String);


private

   type Item is new a_Type.item with
      record
         Indication : subtype_Indication.view;

--           main_Type : aliased AdaM.a_Type.view;
--
--           First     : Text;
--           Last      : Text;
      end record;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;


end AdaM.a_Type.a_subtype;
