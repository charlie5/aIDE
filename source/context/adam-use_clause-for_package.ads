with
     Ada.Containers.Vectors,
     Ada.Streams;

private
with
     AdaM.package_Declaration;


package AdaM.use_Clause.for_package
is

   type Item is new use_Clause.item with private;


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
   function  new_Subprogram         return use_Clause.for_package.view;
   procedure free           (Self : in out use_Clause.for_package.view);
   procedure destruct       (Self : in out use_Clause.for_package.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;



private

   type Item is new use_Clause.item with
      record
         Packages : package_Declaration.vector;
      end record;

end AdaM.use_Clause.for_package;
