package AdaM.Any
--
-- Allows any class to be made persistent.
--
is

   type Item is interface;

   function Id (Self : access Item) return AdaM.Id
     is abstract;



   type view_Resolver is access procedure;

   procedure register_view_Resolver (the_Resolver : in view_Resolver);

   procedure resolve_all_Views;

end AdaM.Any;
