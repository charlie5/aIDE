with
     AdaM.Any,
     AdaM.library_Unit,

     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.library_Item
is

   type Item is new Any.item with private;


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
   function  new_Item (Unit : in AdaM.library_Unit.view) return library_Item.view;

   procedure free           (Self : in out library_Item.view);
   procedure destruct       (Self : in out library_Item.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;

   procedure Unit_is (Self : in out Item;   Now : AdaM.library_Unit.view);
   function  Unit    (Self : in     Item)  return AdaM.library_Unit.view;



private

   type Item is new Any.item with
      record
         library_Unit : AdaM.library_Unit.view;
      end record;

end AdaM.library_Item;
