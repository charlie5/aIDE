with
     AdaM.Subprogram;


package body adam.Source.utility
is

   --  Entities
   --


   function contains_Subprograms (the_Entities : in Entities) return Boolean
   is
   begin
      for i in 1 .. the_Entities.Length
      loop
         if the_Entities.Element (Integer (i)).all in Subprogram.item'Class
         then
            return True;
         end if;
      end loop;

--        raise Program_Error with "TODO";
      return False;
   end contains_Subprograms;


end adam.Source.utility;
