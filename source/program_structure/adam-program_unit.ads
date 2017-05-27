with
     AdaM.Any,
     AdaM.Entity,

     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.program_Unit
is

   type Item is abstract new Any.item
                         and Entity.item with private;


   -- View
   --
   type View is access all Item'Class;

--     procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--                           Self   : in              View);
--
--     procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--                           Self   : out             View);
--
--     for View'write use View_write;
--     for View'read  use View_read;


   --  Vector
   --
   package Vectors is new ada.Containers.Vectors (Positive, View);
   subtype Vector  is     Vectors.Vector;


   --  Forge
   --
--     function  new_Subprogram         return program_Unit.view;
--     procedure free           (Self : in out program_Unit.view);
   procedure destruct       (Self : in out program_Unit.item);


   -- Attributes
   --

--     overriding
--     function Id (Self : access Item) return AdaM.Id;



private

   package Entity is new Entity.make_Entity (Any.item);


--     type Item is new Any.item with
   type Item is abstract new Entity.item with
      record
         null;
      end record;

end AdaM.program_Unit;
