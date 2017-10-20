with
     Ada.Streams;


package AdaM.a_Type.record_type
is

   type Item is new a_Type.composite_Type with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Type (Name : in     String := "") return record_type.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out record_type.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return AdaM.Id;


   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector;


   function  is_Abstract (Self : in     Item)     return Boolean;
   procedure is_Abstract (Self :    out Item;   Now : in Boolean := True);

   function  is_Tagged   (Self : in     Item)     return Boolean;
   procedure is_Tagged   (Self :    out Item;   Now : in Boolean := True);

   function  is_Limited  (Self : in     Item)     return Boolean;
   procedure is_Limited  (Self :    out Item;   Now : in Boolean := True);



private

   type Item is new a_Type.composite_Type with
      record
         is_Abstract : Boolean;
         is_Tagged   : Boolean;
         is_Limited  : Boolean;
      end record;



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.a_Type.record_type;
