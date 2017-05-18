with
     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.Declaration.of_renaming.a_subprogram
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
   function  new_Subprogram         return Declaration.of_renaming.a_subprogram.view;
   procedure free           (Self : in out Declaration.of_renaming.a_subprogram.view);
   procedure destruct       (Self : in out Declaration.of_renaming.a_subprogram.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;



private

   type Item is new Declaration.item with
      record
         null;
      end record;

end AdaM.Declaration.of_renaming.a_subprogram;
