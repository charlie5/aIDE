with
     ada.Containers.Vectors;


package body AdaM.Any
is

   package view_resolver_Vectors is new ada.Containers.Vectors (Positive, view_Resolver);

   all_Resolvers : view_resolver_Vectors.Vector;



   procedure register_view_Resolver (the_Resolver : in view_Resolver)
   is
   begin
      all_Resolvers.append (the_resolver);
   end register_view_Resolver;



   procedure resolve_all_Views
   is
      use view_resolver_Vectors;
      Cursor : view_resolver_Vectors.Cursor := all_Resolvers.First;
   begin
      while has_Element (Cursor)
      loop
         Element (Cursor).all;
         next (Cursor);
      end loop;
   end resolve_all_Views;

end AdaM.Any;
