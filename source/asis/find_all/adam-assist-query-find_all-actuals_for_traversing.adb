package body AdaM.Assist.Query.find_All.Actuals_for_traversing
is

   -------------
   -- Post_Op --
   -------------

   procedure Post_Op
     (Element :        Asis.Element;
      Control : in out Asis.Traverse_Control;
      State   : in out Traversal_State)
   is separate;

   ------------
   -- Pre_Op --
   ------------

   procedure Pre_Op
     (Element :        Asis.Element;
      Control : in out Asis.Traverse_Control;
      State   : in out Traversal_State)
   is separate;

end AdaM.Assist.Query.find_All.Actuals_for_traversing;
