with
     AdaM.Entity,
     AdaM.Block,
     AdaM.Context,
     AdaM.Parameter,

     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.Subprogram
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


   --  Forge
   --

   function  new_Subprogram (Name : in     String := "") return Subprogram.view;
   procedure free           (Self : in out Subprogram.view);
   procedure destruct       (Self : in out Subprogram.item);


   --  Attributes
   --

   overriding
   function Id           (Self : access Item) return AdaM.Id;

   overriding
   function  Name        (Self : in     Item)     return String;
   procedure Name_is     (Self : in out Item;   Now : in String);

   overriding
   function to_Source    (Self : in     Item) return text_Vectors.Vector;

   function Context      (Self : in     Item) return AdaM.Context.view;
   function Block        (Self : in     Item) return AdaM.Block.view;

   function is_Function  (Self : in     Item) return Boolean;
   function is_Procedure (Self : in     Item) return Boolean;



private

   type Profile is tagged
      record
         Parameters : Parameter.Vector;
         Result     : Parameter.view;
      end record;

   function to_Source (the_Profile : in Profile) return text_Vectors.Vector;


   type Item is new Entity.item with
      record
         Context      : AdaM.Context.view;
         Name         : Text;
         Profile      : subprogram.Profile;
         Block        : AdaM.Block.view;
      end record;


end AdaM.Subprogram;
