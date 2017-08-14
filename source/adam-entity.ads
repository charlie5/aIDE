with
     AdaM.Any,
     Ada.Streams;


package AdaM.Entity
is

   type Base is abstract tagged null record;

   type Item is abstract new Base
                         and Any.item with private;


   -- View
   --
   type View is access all Item'Class;

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;



   --  Entities
   --
   package Entity_Vectors is new ada.Containers.Vectors (Positive, View);

   type Entities      is new Entity_Vectors.Vector with private;
   type Entities_View is access all Entities;

   function  to_spec_Source (the_Entities : in Entities) return text_Vectors.Vector;
--     function  to_body_Source (the_Entities : in Entities) return text_Vectors.Vector;


   -- Entity Attributes
   --

   overriding
   function  Id        (Self : access Item) return AdaM.Id                 is abstract;

   function  to_Source (Self : in     Item) return text_Vectors.Vector     is abstract;

   function  parent_Entity    (Self : in     Item)     return Entity.view;
   procedure parent_Entity_is (Self : in out Item;   Now : in Entity.View);

   function  Children     (Self : access Item)     return Entities_view;
   function  Children     (Self : in     Item)     return Entities'Class;
   procedure Children_are (Self : in out Item;   Now : in Entities'Class);

   function  Name      (Self : in     Item) return Identifier is abstract;
--     function  full_Name (Self : in Item'Class) return String;



private

   type Item is abstract new Base
                         and Any.item with
      record
         parent_Entity :         Entity.view;
         Children      : aliased Entities;
      end record;


   type Entities is new Entity_Vectors.Vector with null record;

end AdaM.Entity;
