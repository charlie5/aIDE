with
     adam.Source,

     ada.Streams,
     ada.Containers.Vectors;

limited
with
     adam.Block;



package adam.exception_Handler
is

   type Item is new Source.Entity with private;


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

   function  new_Handler (Name   : in String := "";
                          Parent : in adam.Block.view) return exception_Handler.view;

   procedure free        (Self : in out exception_Handler.view);
   procedure destruct    (Self : in out Item);


   --  Attributes
   --

   overriding
   function  Id        (Self : access Item) return adam.Id;

   function  is_Free   (Self : in     Item;   Slot : in Positive) return Boolean;

   function  exception_Name    (Self : in     Item;   Id  : in Positive) return String;
   procedure exception_Name_is (Self : in out Item;   Id  : in Positive;
                                                      Now : in String);

   procedure add_Exception   (Self : in out Item;   Name : in String);
   function  exception_Count (Self : in     Item)     return Natural;

   overriding
   function  to_spec_Source (Self : in     Item) return text_Lines;

   function  Handler   (Self : in     Item) return access adam.Block.item'Class;


   --  Operations
   --



private

   type Item is new Source.Entity with
      record
         Exceptions : text_Lines;
         Handler    : access adam.Block.item'Class;
         Parent     : access adam.Block.item'Class;
      end record;

end adam.exception_Handler;
