with
     AdaM.Declaration.of_package,

     Ada.Containers.Vectors,
     Ada.Streams;

private
with
     AdaM.Declaration.of_subprogram,
     AdaM.Declaration.of_generic,
     AdaM.Declaration.of_instantiation;


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
   type declaration_Kind is (a_Subprogram, a_Package, a_Generic, an_Instantiation);

   function  new_Subprogram   return library_Unit.declaration.view;
   function  new_Package      return library_Unit.declaration.view;
   function  new_Generic      return library_Unit.declaration.view;
   function  new_Intantiation return library_Unit.declaration.view;

   procedure free           (Self : in out library_Unit.declaration.view);
   overriding
   procedure destruct       (Self : in out library_Unit.declaration.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;


   function my_Package (Self : in Item) return AdaM.Declaration.of_package.view;



private

   type a_Declaration (Kind : declaration_Kind := a_Subprogram) is
      record
         case Kind
         is
            when a_Subprogram =>
               of_Subprogram    : AdaM.Declaration.of_subprogram.view;

            when a_Package =>
               of_Package       : AdaM.Declaration.of_package.view;

            when a_Generic =>
               of_Generic       : AdaM.Declaration.of_generic.view;

            when an_Instantiation =>
               of_Instantiation : AdaM.Declaration.of_instantiation.view;
         end case;
      end record;


   type Item is new library_Unit.item with
      record
         Declaration : library_Unit.Declaration.a_Declaration;
      end record;

end AdaM.library_Unit.declaration;
