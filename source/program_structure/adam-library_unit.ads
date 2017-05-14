with
     AdaM.Any,

     Ada.Containers.Vectors,
     Ada.Streams;

private
with
     AdaM.program_Unit;


package AdaM.library_Unit
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
   function  new_Subprogram         return library_Unit.view;
   procedure free           (Self : in out library_Unit.view);
   procedure destruct       (Self : in out library_Unit.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;



private

   type Item is new Any.item with
      record
         Parent   : library_Unit.view;
         Children : library_Unit.vector;

         program_Units : program_Unit.vector;
      end record;

end AdaM.library_Unit;
