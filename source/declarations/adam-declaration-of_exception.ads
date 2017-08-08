with
     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.Declaration.of_exception
is

   type Item is new Declaration.item with private;

   -- View
   --
   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;

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
   function  new_Declaration (Name : in     String) return Declaration.of_exception.view;
   procedure free            (Self : in out Declaration.of_exception.view);
   overriding
   procedure destruct        (Self : in out Declaration.of_exception.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;

   function full_Name (Self : in Item) return String;


   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector;


private

   type Item is new Declaration.item with
      record
         null;
      end record;

end AdaM.Declaration.of_exception;
