with
     Asis;
--       AdaM.Source;

package AdaM.Assist.Query.find_Entities.Actuals_for_traversing
is

   type Traversal_State is
      record
--           parent_Stack   : AdaM.Source.Entities;
         ignore_Starter : asis.Element        := asis.Nil_Element;
      end record;

   Initial_Traversal_State : constant Traversal_State := (others => <>);


   procedure Pre_Op
     (Element :        Asis.Element;
      Control : in out Asis.Traverse_Control;
      State   : in out Traversal_State);

   procedure Post_Op
     (Element :        Asis.Element;
      Control : in out Asis.Traverse_Control;
      State   : in out Traversal_State);

end AdaM.Assist.Query.find_Entities.Actuals_for_traversing;
