with
     adam.Any,
     adam.Source,

     ada.Containers.Vectors,
     ada.Streams;


package adam.compilation_Unit
is

   type Item is new adam.Any.item with private;


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

   function  new_Unit (Name : in     String := "") return compilation_Unit.view;
   procedure free     (Self : in out compilation_Unit.view);
   procedure destruct (Self : in out Item);


   -- Attributes
   --
   overriding
   function  Id      (Self : access Item) return adam.Id;

   procedure add     (Self : in out Item;   Entity : in Source.Entity_View);
   procedure clear   (Self : in out Item);

   function  Length  (Self : in Item) return Natural;
   function  Entity  (Self : in Item;   Index : Positive) return Source.Entity_View;

   function  Name    (Self : in     Item)     return String;
   procedure Name_is (Self : in out Item;   Now : in String);


private

   type Item is new adam.Any.item with
      record
         Name     : Text;
         Entities : Source.Entities;
      end record;


   -- Streams
   --
   procedure Item_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              Item);
   procedure Item_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             Item);

   for Item'write use Item_write;
   for Item'read  use Item_read;

end adam.compilation_Unit;
