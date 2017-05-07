package body adam.Source
is

   --  Entities
   --

   function to_spec_Source (the_Entities : in Entities) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      for Each of the_Entities
      loop
         the_Source.append (Each.to_spec_Source);
      end loop;

      return the_Source;
   end to_spec_Source;


   function to_body_Source (the_Entities : in Entities) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      for Each of the_Entities
      loop
         the_Source.append (Each.to_body_Source);
      end loop;

      return the_Source;
   end to_body_Source;



   -- Entity
   --

   procedure add_Child (Self : in out Entity;   Child : in Entity_View)
   is
   begin
      Self.Children.append (Child);
   end add_Child;


   procedure rid_Child (Self : in out Entity;   Child : in Entity_View)
   is
   begin
      Self.Children.delete (Self.Children.find_Index (Child));
   end rid_Child;



   function Name (Self : in Entity) return String
   is
      pragma Unreferenced (Self);
   begin
      return "<anon>";
   end Name;



   function to_spec_Source (Self : in Entity) return text_Vectors.Vector
   is
      pragma Unreferenced (Self);
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_spec_Source;


   function to_body_Source (Self : in Entity) return text_Vectors.Vector
   is
      pragma Unreferenced (Self);
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_body_Source;


   overriding
   function Id (Self : access Entity) return adam.Id
   is
      pragma Unreferenced (Self);
   begin
      raise Program_Error with "Source.Entity Id must be overridden";
      return adam.Id'Last;
   end Id;


end adam.Source;
