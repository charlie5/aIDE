with
     AdaM.Any;


package AdaM.Source
is
   type Entity      is new Any.Item with private;
   type Entity_View is access all Entity'Class;


   --  Entities
   --
   package Entity_Vectors is new ada.Containers.Vectors (Positive, Entity_View);

   type Entities      is new Entity_Vectors.Vector with private;
   type Entities_View is access all Entities;

   function  to_spec_Source (the_Entities : in Entities) return text_Vectors.Vector;
   function  to_body_Source (the_Entities : in Entities) return text_Vectors.Vector;


   -- Entity Attributes
   --

   function  to_spec_Source (Self : in Entity) return text_Vectors.Vector;
   function  to_body_Source (Self : in Entity) return text_Vectors.Vector;

   procedure add_Child (Self : in out Entity;   Child : in Entity_View);
   procedure rid_Child (Self : in out Entity;   Child : in Entity_View);

   function  Name (Self : in Entity) return String;



private

   type Entity is  new Any.item with
      record
         Children : Entities;
      end record;

   overriding
   function Id (Self : access Entity) return AdaM.Id;


   type Entities is new Entity_Vectors.Vector with null record;

end AdaM.Source;
