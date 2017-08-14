with
     Ada.Containers.Vectors;


package AdaM.program_Unit
is

   type Item is interface;


   -- View
   --
   type View is access all Item'Class;

   --  Vector
   --
   package Vectors is new ada.Containers.Vectors (Positive, View);
   subtype Vector  is     Vectors.Vector;


private

   procedure dummy;

end AdaM.program_Unit;
