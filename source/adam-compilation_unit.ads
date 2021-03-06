with
     AdaM.Any,
     AdaM.Entity,
     AdaM.Context,
     AdaM.library_Item,
     AdaM.Subunit,

     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.compilation_Unit
is

   type Item is new AdaM.Any.item with private;


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
   function  new_compilation_Unit (Name : in String := "") return compilation_Unit.view;


   type unit_Kind is (library_unit_Kind, subunit_Kind);

   function  new_library_Unit (Name     : in String := "";
                               the_Item : in library_Item.view) return compilation_Unit.view;

   function  new_Subunit      (Name     : in String := "";
                              the_Unit  : in Subunit.view) return compilation_Unit.view;

   procedure free     (Self : in out compilation_Unit.view);
   procedure destruct (Self : in out Item);


   -- Attributes
   --
   overriding
   function  Id           (Self : access Item) return AdaM.Id;

   function  Kind         (Self : in Item) return unit_Kind;
   function  library_Item (Self : in Item) return AdaM.library_Item.view;

   function  Name         (Self : in     Item)     return String;
   procedure Name_is      (Self : in out Item;   Now : in String);

   function  Entity       (Self : in     Item)     return AdaM.Entity.view;
   procedure Entity_is    (Self : in out Item;   Now : in AdaM.Entity.view);



private

   type library_Item_or_Subunit (Kind : unit_Kind := library_unit_Kind) is
      record
         case Kind
         is
            when library_unit_Kind =>
               library_Item : AdaM.library_Item.view;

            when subunit_Kind =>
               Subunit      : AdaM.Subunit.view;
         end case;
      end record;


   type Item is new AdaM.Any.item with
      record
         Name         : Text;
         Context      : AdaM.Context.view;
         library_Item : library_Item_or_Subunit;
         Entity       : AdaM.Entity.view;
      end record;


   -- Streams
   --
   procedure Item_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              Item);
   procedure Item_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             Item);

   for Item'write use Item_write;
   for Item'read  use Item_read;

end AdaM.compilation_Unit;
