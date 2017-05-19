with
     AdaM.Source,
     ada.Streams;


package AdaM.a_Type
is

   type Item is abstract new Source.Entity with private;


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


   -- Forge
   --

   procedure destruct (Self : in out Item);



   --  Attributes
   --

   function  Name      (Self : in     Item) return String;
   procedure Name_is   (Self : in out Item;   Now : in String);


   --  Ada Type Hierachy
   --

   type elementary_Type is abstract new a_Type.item with private;
   type composite_Type  is abstract new a_Type.item with private;

--     type access_Type is new elementary_Type with private;
   type scalar_Type is abstract new elementary_Type with private;

   type discrete_Type is abstract new scalar_Type with private;
   type real_Type     is abstract new scalar_Type with private;

   type integer_Type is abstract new discrete_Type with private;
   type fixed_Type   is abstract new real_Type     with private;



private

   type Item is abstract new Source.Entity with
      record
         Name : Text;
      end record;


   --  Ada Type Hierachy
   --

   type elementary_Type is abstract new a_Type.item with null record;
   type composite_Type  is abstract new a_Type.item with null record;

--     type access_Type is new elementary_Type with null record;
   type scalar_Type is abstract new elementary_Type with null record;

   type discrete_Type is abstract new scalar_Type with null record;
   type real_Type     is abstract new scalar_Type with null record;

   type integer_Type is abstract new discrete_Type with null record;
   type fixed_Type   is abstract new     real_Type with null record;

end AdaM.a_Type;
