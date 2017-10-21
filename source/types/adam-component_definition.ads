with
     AdaM.Entity,
     AdaM.subtype_Indication,
     AdaM.access_Definition,

     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.component_Definition
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
   function  new_Definition (is_subtype_Indication : in Boolean) return component_Definition.view;

   procedure free     (Self : in out component_Definition.view);
   procedure destruct (Self : in out component_Definition.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;

   overriding
   function  Name    (Self : in     Item)     return Identifier;

   procedure is_Aliased  (Self : in out Item;   Now : in Boolean := True);
   function  is_Aliased  (Self : in     Item)     return Boolean;

--     procedure subtype_Indication_is (Self :    out Item;   Now : in subtype_Indication.view);
--     procedure access_Definition_is  (Self :    out Item;   Now : in access_Definition.view);

   function  is_subtype_Indication (Self : in Item) return Boolean;
   function  is_access_Definition  (Self : in Item) return Boolean;

   function  subtype_Indication (Self : in Item) return subtype_Indication.view;
   function  access_Definition  (Self : in Item) return access_Definition.view;


--     procedure Type_is (Self : in out Item;   Now : in AdaM.a_Type.view);
--     function  my_Type (Self : in     Item)     return AdaM.a_Type.view;
--     function  my_Type (Self : access Item)     return access AdaM.a_Type.view;

   overriding
   function  to_Source (Self : in     Item) return text_Vectors.Vector;



private

   type Item is new Entity.item with
      record
         is_Aliased : Boolean := False;

         subtype_Indication : AdaM.subtype_Indication.view;
         access_Definition  : AdaM.access_Definition .view;
      end record;

end AdaM.component_Definition;
