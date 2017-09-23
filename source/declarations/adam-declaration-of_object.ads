with
     AdaM.a_Type,
     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.Declaration.of_object
is

   type Item is new Declaration.item with private;


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
   function  new_Declaration (Name : in String) return Declaration.of_object.view;

   procedure free     (Self : in out Declaration.of_object.view);
   overriding
   procedure destruct (Self : in out Declaration.of_object.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;

   procedure is_Constant (Self : in out Item;   Now : in Boolean := True);
   function  is_Constant (Self : in     Item)     return Boolean;

   procedure Type_is (Self : in out Item;   Now : in AdaM.a_Type.view);
   function  my_Type (Self : in     Item)     return AdaM.a_Type.view;
   function  my_Type (Self : access Item)     return access AdaM.a_Type.view;

   procedure Initialiser_is (Self : in out Item;   Now : in String);
   function  Initialiser    (Self : in     Item)     return String;


private

   type Item is new Declaration.item with
      record
         is_Constant : Boolean             := False;
         my_Type     : aliased a_Type.view;
         Initialiser : Text;
      end record;

end AdaM.Declaration.of_object;
