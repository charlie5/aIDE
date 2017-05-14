with
     AdaM.Source,

     ada.Containers.Vectors,
     ada.Streams;


package AdaM.an_Exception
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


   --  Forge
   --

   function  new_Subprogram (Name : in     String := "") return an_Exception.view;
   procedure free           (Self : in out an_Exception.view);
   procedure destruct       (Self : in out an_Exception.item);


   --  Attributes
   --

   overriding
   function Id           (Self : access Item) return AdaM.Id;

   overriding
   function  Name        (Self : in     Item)     return String;
   procedure Name_is     (Self : in out Item;   Now : in String);

   overriding
   function to_spec_Source (Self : in     Item) return text_Vectors.Vector;



private

   type Item is new Source.Entity with
      record
         Name : Text;
      end record;

end AdaM.an_Exception;
