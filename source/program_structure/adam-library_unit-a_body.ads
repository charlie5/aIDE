with
     Ada.Containers.Vectors,
     Ada.Streams;

private
with
     AdaM.subprogram_Body,
     AdaM.package_Body;


package AdaM.library_Unit.a_body
is

   type Item is new library_Unit.item with private;


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
   function  new_Subprogram         return library_Unit.a_body.view;
   procedure free           (Self : in out library_Unit.a_body.view);
   overriding
   procedure destruct       (Self : in out library_Unit.a_body.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;



private

   type declaration_Kind is (subprogram_Body, package_Body);

   type a_Declaration (Kind : declaration_Kind := subprogram_Body) is
      record
         case Kind
         is
            when subprogram_Body =>
               of_Subprogram : AdaM.subprogram_Body.view;

            when package_Body =>
               of_Package    : AdaM.package_Body.view;
         end case;
      end record;


   type Item is new library_Unit.item with
      record
         Declaration : a_Declaration;
      end record;

end AdaM.library_Unit.a_body;
