with
     Ada.Streams;


package AdaM.a_Type.unconstrained_array_type
is

   type Item is new a_Type.composite_Type with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Type (Name : in     String := "") return unconstrained_array_type.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out unconstrained_array_type.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return AdaM.Id;


   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector;


   function  index_Type      (Self : access Item) return access AdaM.a_Type.view;
   function  index_Type      (Self : in     Item) return        AdaM.a_Type.view;
   procedure index_Type_is   (Self : in out Item;   Now : in AdaM.a_Type.view);

   function  element_Type    (Self : access Item) return access AdaM.a_Type.view;
   function  element_Type    (Self : in     Item) return        AdaM.a_Type.view;
   procedure element_Type_is (Self : in out Item;   Now : in AdaM.a_Type.view);

   function  First    (Self : in     Item)     return String;
   procedure First_is (Self : in out Item;   Now : in String);

   function  Last    (Self : in     Item)     return String;
   procedure Last_is (Self : in out Item;   Now : in String);

   function  is_Constrained (Self : in     Item)     return Boolean;
   procedure is_Constrained (Self : in out Item;   Now : in Boolean := True);



private

   type Item is new a_Type.composite_Type with
      record
         index_Type     : aliased AdaM.a_Type.view;
         element_Type   : aliased AdaM.a_Type.view;

         is_Constrained : Boolean;
         First          : Text;
         Last           : Text;
      end record;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.a_Type.unconstrained_array_type;
