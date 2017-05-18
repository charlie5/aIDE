with
     AdaM.context_Item,

     Ada.Containers.Vectors,
     Ada.Streams;

private
with
    AdaM.Declaration.of_package;


package AdaM.with_Clause
is

   type Item is new context_Item.item with private;


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
   function  new_Subprogram         return with_Clause.view;
   procedure free           (Self : in out with_Clause.view);
   procedure destruct       (Self : in out with_Clause.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;



private

   type Item is new context_Item.item with
      record
         is_Limited : Boolean;
         is_Private : Boolean;

         Packages   : Declaration.of_package.vector;
      end record;

end AdaM.with_Clause;
