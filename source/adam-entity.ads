with
     AdaM.Any,
     Ada.Streams;


package AdaM.Entity
is

   type Base is abstract tagged null record;

--     type Item is limited interface;
--     type Item is abstract tagged limited and Any.item private;
--     type Item is abstract new Any.item with private;
--     type Item is interface and Any.item;

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

--     function  parent_Entity    (Self : in     Item)     return Entity.view   is abstract;
--     procedure parent_Entity_is (Self : in out Item;   Now : in Entity.View)  is abstract;
--
--     function  Children     (Self : access Item)     return Entities_view   is abstract;
--     function  Children     (Self : in     Item)     return Entities'Class  is abstract;
--     procedure Children_are (Self : in out Item;   Now : in Entities'Class) is abstract;


   function  parent_Entity    (Self : in     Item)     return Entity.view;
   procedure parent_Entity_is (Self : in out Item;   Now : in Entity.View);

   function  Children     (Self : access Item)     return Entities_view;
   function  Children     (Self : in     Item)     return Entities'Class;
   procedure Children_are (Self : in out Item;   Now : in Entities'Class);





--     procedure add_Child (Self : in out Item;   Child : in Entity.view)  is abstract;
--     procedure rid_Child (Self : in out Entity;   Child : in Entity_View)  is abstract;

   function  Name      (Self : in     Item) return String is abstract;

--     function  full_Name (Self : in Item'Class) return String;


--     generic
--        type T is abstract tagged private;
--     package make_Entity
--     --
--     --  Makes a user class T into an Entity item.
--     --
--     is
--        type Item is abstract new T
--                              and Entity.item with private;
--
--        -- View
--        --
--        type View is access all Item'Class;
--
--  --        procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--  --                              Self   : in              View);
--  --
--  --        procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--  --                              Self   : out             View);
--  --
--  --        for View'write use View_write;
--  --        for View'read  use View_read;
--
--
--        overriding
--        function  parent_Entity    (Self : in     Item)       return Entity.view;
--
--        overriding
--        procedure parent_Entity_is (Self : in out Item;   Now : in Entity.View);
--
--        overriding
--        function  Children  (Self : access Item)     return Entities_view;
--
--        overriding
--        function  Children  (Self : in     Item)     return Entities'Class;
--
--        overriding
--        procedure Children_are (Self : in out Item;   Now : in Entities'Class);
--
--
--     private
--
--        type Item is abstract  new T
--                               and Entity.item
--        with
--           record
--              parent_Entity   :         Entity.view;
--              Children : aliased Entities;
--           end record;
--
--     end make_Entity;



private

--     type Item is abstract tagged limited
--     type Item is interface and Any.item
--        record
--           parent_Entity   :         Entity.view;
--           Children      : aliased Entities;
--        end record;



   type Item is abstract new Base
                         and Any.item with
      record
         parent_Entity :         Entity.view;
         Children      : aliased Entities;
      end record;




--     type Entity is  new Any.item with
--        record
--           Children : Entities;
--        end record;

--     overriding
--     function Id (Self : access Item) return AdaM.Id is abstract;


   type Entities is new Entity_Vectors.Vector with null record;

end AdaM.Entity;
