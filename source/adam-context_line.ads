with
     AdaM.Any,
     ada.Streams;


package AdaM.context_Line
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

   function  to_Source (the_Lines : in     Vector) return text_Vectors.Vector;



   --  Forge
   --

   function  new_context_Line (Name : in     String := "") return context_Line.view;
   procedure free             (Self : in out context_Line.view);

   procedure destruct         (Self : in out Item);



   --  Attributes
   --

   overriding function  Id        (Self : access Item) return AdaM.Id;

   function  to_Source (Self : in Item) return text_Vectors.Vector;

   function  Name      (Self : access Item)     return access Text;
   function  Name      (Self : in     Item)     return String;
   procedure Name_is   (Self : in out Item;   Now : in String);

   function  is_Used   (Self : in     Item)     return Boolean;
   procedure is_Used   (Self : in out Item;   Now : in Boolean);



private

   type Item is new Any.Item with
      record
         package_Name : aliased Text;
         Used         :         Boolean;
      end record;

end AdaM.context_Line;
