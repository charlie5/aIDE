package body AdaM.Entity
is

   --  Entities
   --

   function to_spec_Source (the_Entities : in Entities) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      for Each of the_Entities
      loop
         the_Source.append (Each.to_Source);
      end loop;

      return the_Source;
   end to_spec_Source;



   -- Entity
   --

--     procedure add_Child (Self : in out Entity;   Child : in Entity_View)
--     is
--     begin
--        Self.Children.append (Child);
--     end add_Child;
--
--
--     procedure rid_Child (Self : in out Entity;   Child : in Entity_View)
--     is
--     begin
--        Self.Children.delete (Self.Children.find_Index (Child));
--     end rid_Child;



--     function Name (Self : in Item) return String
--     is
--        pragma Unreferenced (Self);
--     begin
--        return "<anon>";
--     end Name;



   function to_spec_Source (Self : in Item) return text_Vectors.Vector
   is
      pragma Unreferenced (Self);
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_spec_Source;



--     overriding
--     function Id (Self : access Entity) return AdaM.Id
--     is
--        pragma Unreferenced (Self);
--     begin
--        raise Program_Error with "Source.Entity Id must be overridden";
--        return AdaM.Id'Last;
--     end Id;







   package body make_Entity
   is

      overriding
      function  Parent    (Self : in     Item)       return Entity.view
      is
      begin
         return Self.Parent;
      end Parent;


      overriding
      procedure Parent_is (Self : in out Item;   Now : in Entity.View)
      is
      begin
         Self.Parent := Now;
      end Parent_is;


      overriding
      function  Children  (Self : access Item)     return Entities_view
      is
      begin
         return Self.Children'Access;
      end Children;

   end make_Entity;






end AdaM.Entity;
