with
     AdaM.Entity,
     AdaM.Declaration.of_exception,

     ada.Streams,
     ada.Containers.Vectors;

limited
with
     adam.Block;



package AdaM.exception_Handler
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

   function  to_Source (the_exception_Handlers : in Vector) return text_Vectors.Vector;


   --  Forge
   --

   type Block_view is access all Block.item'Class;

   procedure Block_view_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                               Self   : in              Block_view);

   procedure Block_view_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                               Self   : out             Block_view);

   for Block_view'write use Block_view_write;
   for Block_view'read  use Block_view_read;


   function  new_Handler (-- Name   : in String := "";
                          Parent : in AdaM.Block.view) return exception_Handler.view;

   procedure free        (Self : in out exception_Handler.view);
   procedure destruct    (Self : in out Item);


   --  Attributes
   --

   overriding
   function  Id        (Self : access Item) return AdaM.Id;

   function  is_Free   (Self : in     Item;   Slot : in Positive) return Boolean;

   function  my_Exception    (Self : in     Item;   Id  : in Positive) return Declaration.of_exception.view;
   procedure my_Exception_is (Self : in out Item;   Id  : in Positive;
                                                    Now : in Declaration.of_exception.view);

   procedure add_Exception   (Self : in out Item;   the_Exception : in AdaM.Declaration.of_exception.view);
   function  exception_Count (Self : in     Item)     return Natural;

   overriding
   function  to_Source (Self : in     Item) return text_Lines;

   function  Handler   (Self : in     Item) return access AdaM.Block.item'Class;

   overriding
   function  Name      (Self : in     Item) return Identifier;


   --  Operations
   --



private

   type Item is new Entity.item with
      record
         Exceptions :        AdaM.Declaration.of_exception.vector;
         Handler    : Block_view; -- access AdaM.Block.item'Class;
         Parent     : Block_view; -- access AdaM.Block.item'Class;
      end record;

end AdaM.exception_Handler;
