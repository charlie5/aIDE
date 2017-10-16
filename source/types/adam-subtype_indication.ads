with
     AdaM.Entity,
     AdaM.a_Type,

     Ada.Streams;


package AdaM.subtype_Indication
is

   type Item is new Entity.item with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Indication (Name : in     String := "") return subtype_Indication.view;

   procedure destruct (Self : in out Item);

   procedure free     (Self : in out subtype_Indication.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return AdaM.Id;

   overriding
   function  Name      (Self : in     Item) return Identifier;

   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector;


   function  has_not_Null (Self : in     Item)     return Boolean;
   procedure has_not_Null (Self : in out Item;   Now : in Boolean := True);

   function  main_Type    (Self : access Item)     return access AdaM.a_Type.view;
   function  main_Type    (Self : in     Item)     return AdaM.a_Type.view;
   procedure main_Type_is (Self : in out Item;   Now : in AdaM.a_Type.view);


   function  First    (Self : in     Item)     return String;
   procedure First_is (Self : in out Item;   Now : in String);

   function  Last    (Self : in     Item)     return String;
   procedure Last_is (Self : in out Item;   Now : in String);

   function  is_Constrained (Self : in     Item) return Boolean;
   procedure is_Constrained (Self : in out Item;   Now : in Boolean := True);



private

   type Item is new Entity.item with
      record
         has_not_Null : Boolean := False;
         main_Type    : aliased AdaM.a_Type.view;

         is_Constrained : Boolean;
         First        : Text;
         Last         : Text;
      end record;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;


end AdaM.subtype_Indication;
