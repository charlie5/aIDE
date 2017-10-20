with
     AdaM.Entity,
     AdaM.a_Type,

     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.record_Component
is

   type Item is new Entity.item with private;


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
   function  new_Component (Name : in String) return record_Component.view;

   procedure free     (Self : in out record_Component.view);
   procedure destruct (Self : in out record_Component.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;

   overriding
   function  Name    (Self : in     Item)     return Identifier;
   procedure Name_is (Self :    out Item;   Now : in Identifier);

   procedure is_Aliased  (Self : in out Item;   Now : in Boolean := True);
   function  is_Aliased  (Self : in     Item)     return Boolean;

   procedure Type_is (Self : in out Item;   Now : in AdaM.a_Type.view);
   function  my_Type (Self : in     Item)     return AdaM.a_Type.view;
   function  my_Type (Self : access Item)     return access AdaM.a_Type.view;

   procedure Initialiser_is (Self : in out Item;   Now : in String);
   function  Initialiser    (Self : in     Item)     return String;

   overriding
   function  to_Source (Self : in     Item) return text_Vectors.Vector;


private

   type Item is new Entity.item with
      record
         Name        :         Text;
         is_Aliased  :         Boolean    := False;
         my_Type     : aliased a_Type.view;
         Initialiser :         Text;
      end record;

end AdaM.record_Component;
