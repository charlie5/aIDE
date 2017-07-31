with
     AdaM.program_Unit,
     AdaM.Declaration,
     AdaM.a_Type,
     AdaM.Context,
     AdaM.Declaration.of_exception,

     Ada.Streams;


package AdaM.Declaration.of_package
is

--     type Item is new program_Unit.Item with private;
   type Item is new Declaration.item
                and program_Unit.item with private;


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

   function  new_Package (Name : in     String := "") return Declaration.of_package.view;
   procedure free        (Self : in out Declaration.of_package.view);

   overriding
   procedure destruct    (Self : in out Item);


   --  Attributes
   --

   overriding
   function  Id               (Self : access Item) return AdaM.Id;

--     overriding
--     function  Name             (Self : in     Item)     return String;
--     overriding
--     procedure Name_is          (Self : in out Item;   Now : in String);

   overriding
   function  to_Source        (Self : in     Item) return text_Vectors.Vector;
   function  to_spec_Source   (Self : in     Item) return text_Vectors.Vector;
   function  to_body_Source   (Self : in     Item) return text_Vectors.Vector;

   function  Context          (Self : in     Item) return Context.view;

--     function  public_Entities     (Self : access Item) return access Source.Entities;
--     procedure public_Entities_are (Self : in out Item;   Now : in Source.Entities);
--
--     procedure add           (Self : in out Item;   the_Declaration : in Source.Entity_View);
--     procedure rid           (Self : in out Item;   the_Declaration : in Source.Entity_View);

   function  all_Exceptions (Self : access     Item) return AdaM.Declaration.of_exception.Vector;

   function  requires_Body (Self : in Item) return Boolean;


   procedure Parent_is (Self : in out Item;   Now : in Declaration.of_package.View);
   function  Parent    (Self : in     Item) return Declaration.of_package.view;

--     function  Children  (Self : in     Item'Class) return a_Package.Vector;
   function  child_Packages  (Self : in     Item'Class) return Declaration.of_package.Vector;
   function  child_Package   (Self : in     Item'Class;   Named : in String) return Declaration.of_package.view;

   procedure add_Child (Self : in out Item;   Child : in Declaration.of_package.view);

   function  find (Self : in Item;   Named : in String) return AdaM.a_Type.view;




private


--     type Item is new program_Unit.item with
   type Item is new Declaration.item
                and program_Unit.item with
      record
         Parent         : Declaration.of_package.view;
         Progenitors    : Declaration.of_package.Vector;
         child_Packages : Declaration.of_package.Vector;

         Context      : AdaM.Context.view;

--           public_Entities  : aliased Source.Entities;
--           private_Entities :         Source.Entities;
--           body_Entities    :         Source.Entities;
      end record;


   -- Streams
   --
   procedure Item_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              Item);
   procedure Item_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             Item);

   for Item'write use Item_write;
   for Item'read  use Item_read;

end AdaM.Declaration.of_package;
