package aIDE.Palette
is

   type Item is abstract tagged private;
   type View is access all Item'Class;



private

   type Item is abstract tagged
      record
         null;
      end record;


   procedure dummy;

end aIDE.Palette;
