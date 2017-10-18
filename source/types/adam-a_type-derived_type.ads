with
     AdaM.a_Type.record_type,
     AdaM.subtype_Indication,
     Ada.Streams;


package AdaM.a_Type.derived_type
is

   type Item is new a_Type.record_type.item with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Type (Name : in     String := "") return derived_type.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out derived_type.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return AdaM.Id;


   function  parent_Subtype    (Self : in     Item)     return subtype_Indication.view;
   procedure parent_Subtype_is (Self :    out Item;   Now : in subtype_Indication.view);


private

   type Item is new a_Type.record_type.item with
      record
         is_Abstract    : Boolean := False;
         is_Limited     : Boolean := False;

         parent_Subtype : subtype_Indication.view;
      end record;



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.a_Type.derived_type;
