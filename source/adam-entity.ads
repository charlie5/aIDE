
package AdaM.Entity
is

   type Item is limited interface;
   type View is access all Item'Class;


   --  Entities
   --
   package Entity_Vectors is new ada.Containers.Vectors (Positive, View);

   type Entities      is new Entity_Vectors.Vector with private;
   type Entities_View is access all Entities;

   function  to_spec_Source (the_Entities : in Entities) return text_Vectors.Vector;
--     function  to_body_Source (the_Entities : in Entities) return text_Vectors.Vector;


   -- Entity Attributes
   --

   function  to_Source (Self : in     Item) return text_Vectors.Vector     is abstract;

   function  Parent    (Self : in     Item)     return Entity.view   is abstract;
   procedure Parent_is (Self : in out Item;   Now : in Entity.View)  is abstract;

   function  Children  (Self : access Item)     return Entities_view is abstract;


--     procedure add_Child (Self : in out Item;   Child : in Entity.view)  is abstract;
--     procedure rid_Child (Self : in out Entity;   Child : in Entity_View)  is abstract;

   function  Name      (Self : in     Item) return String is abstract;



   generic
      type T is abstract tagged private;
   package make_Entity
   --
   --  Makes a user class T into an Entity item.
   --
   is
      type Item is abstract new T
                            and Entity.item with private;
      type View is access all Item'Class;


      overriding
      function  Parent    (Self : in     Item)       return Entity.view;

      overriding
      procedure Parent_is (Self : in out Item;   Now : in Entity.View);

      overriding
      function  Children  (Self : access     Item)     return Entities_view;

   private

      type Item is abstract  new T
                             and Entity.item
      with
         record
            Parent   :         Entity.view;
            Children : aliased Entities;
         end record;

   end make_Entity;



private

--     type Entity is  new Any.item with
--        record
--           Children : Entities;
--        end record;

--     overriding
--     function Id (Self : access Item) return AdaM.Id is abstract;


   type Entities is new Entity_Vectors.Vector with null record;

end AdaM.Entity;
