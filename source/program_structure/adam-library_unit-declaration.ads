with
     AdaM.Any,

     Ada.Containers.Vectors,
     Ada.Streams;

private
with
     AdaM.subprogram_Declaration,
     AdaM.package_Declaration,
     AdaM.generic_Declaration,
     AdaM.generic_Instantiation;


package AdaM.library_Unit.declaration
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
   function  new_Subprogram         return library_Unit.declaration.view;
   procedure free           (Self : in out library_Unit.declaration.view);
   procedure destruct       (Self : in out library_Unit.declaration.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;



private

   type declaration_Kind is (a_Subprogram, a_Package, a_Generic, an_Instantiation);

   type a_Declaration (Kind : declaration_Kind := a_Subprogram) is
      record
         case Kind
         is
            when a_Subprogram =>
               of_Subprogram    : AdaM.subprogram_Declaration.view;

            when a_Package =>
               of_Package       : AdaM.package_Declaration.view;

            when a_Generic =>
               of_Generic       : AdaM.generic_Declaration.view;

            when an_Instantiation =>
               of_Instantiation : AdaM.generic_Instantiation.view;
         end case;
      end record;


   type Item is new library_Unit.item with
      record
         Declaration : library_Unit.Declaration.a_Declaration;
      end record;

end AdaM.library_Unit.declaration;
