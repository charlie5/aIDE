with
     AdaM.Any,
     AdaM.Source,
     AdaM.Context,

     ada.Streams;


package AdaM.a_Package
is

   type Item is new Any.Item with private;


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

   function  new_Package (Name : in     String := "") return a_Package.view;
   procedure free        (Self : in out a_Package.view);

   procedure destruct    (Self : in out Item);


   --  Attributes
   --

   overriding
   function  Id               (Self : access Item) return AdaM.Id;

   function  Name             (Self : in     Item)     return String;
   procedure Name_is          (Self : in out Item;   Now : in String);

   function  to_spec_Source   (Self : in     Item) return text_Vectors.Vector;
   function  to_body_Source   (Self : in     Item) return text_Vectors.Vector;

   function  Context          (Self : in     Item) return Context.view;

   function  public_Entities     (Self : access Item) return access Source.Entities;
   procedure public_Entities_are (Self : in out Item;   Now : in Source.Entities);

   procedure add           (Self : in out Item;   the_Declaration : in Source.Entity_View);
   procedure rid           (Self : in out Item;   the_Declaration : in Source.Entity_View);

   function  requires_Body (Self : in Item) return Boolean;


   procedure Parent_is (Self : in out Item;   Now : in a_Package.View);
   function  Parent    (Self : in     Item) return a_Package.view;

   function  Children  (Self : in     Item'Class) return a_Package.Vector;

   procedure add_Child (Self : in out Item;   Child : in a_Package.View);



private


   type Item is new Any.Item with
      record
         Name         : Text;

         Parent       : a_Package.view;
         Progenitors  : a_Package.Vector;
         Children     : a_Package.Vector;

         Context      : AdaM.Context.view;

         public_Entities  : aliased Source.Entities;
         private_Entities :         Source.Entities;
         body_Entities    :         Source.Entities;
      end record;


   -- Streams
   --
   procedure Item_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              Item);
   procedure Item_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             Item);

   for Item'write use Item_write;
   for Item'read  use Item_read;

end AdaM.a_Package;
