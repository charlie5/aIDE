with
     Ada.Containers.Vectors,
     Ada.Streams;

private
with
     AdaM.Declaration.of_renaming.a_subprogram,
     AdaM.Declaration.of_renaming.a_package,
     AdaM.Declaration.of_renaming.a_generic;


package AdaM.library_Unit.renaming_declaration
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
   function  new_Subprogram         return library_Unit.renaming_declaration.view;
   procedure free           (Self : in out library_Unit.renaming_declaration.view);
   overriding
   procedure destruct       (Self : in out library_Unit.renaming_declaration.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;



private

   type Kind is (   package_renaming_Declaration,
                    generic_renaming_Declaration,
                 subprogram_renaming_Declaration);

   type a_Declaration (Kind : renaming_declaration.Kind := package_renaming_Declaration) is
      record
         case Kind
         is
            when package_renaming_Declaration =>
               of_package_Renaming    : AdaM.Declaration.of_renaming.a_package.view;

            when generic_renaming_Declaration =>
               of_generic_Renaming    : AdaM.Declaration.of_renaming.a_generic.view;

            when subprogram_renaming_Declaration =>
               of_subprogram_Renaming : AdaM.Declaration.of_renaming.a_subprogram.view;
         end case;
      end record;


   type Item is new library_Unit.item with
      record
         Declaration : a_Declaration;
      end record;

end AdaM.library_Unit.renaming_declaration;
