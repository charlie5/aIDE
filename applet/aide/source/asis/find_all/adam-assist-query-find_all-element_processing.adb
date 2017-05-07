with
     Asis.Iterator,
     adam.Assist.Query.find_All.Actuals_for_traversing;


package body adam.Assist.Query.find_All.element_Processing
is

   procedure Recursive_Construct_Processing is new
      Asis.Iterator.Traverse_Element
        (State_Information => adam.Assist.Query.find_All.Actuals_for_traversing.Traversal_State,
         Pre_Operation     => adam.Assist.Query.find_All.Actuals_for_traversing.Pre_Op,
         Post_Operation    => adam.Assist.Query.find_All.Actuals_for_traversing.Post_Op);



   procedure Process_Construct (The_Element : Asis.Element)
   is
      Process_Control : Asis.Traverse_Control := Asis.Continue;
      Process_State   : adam.Assist.Query.find_All.Actuals_for_traversing.Traversal_State
        := adam.Assist.Query.find_All.Actuals_for_traversing.Initial_Traversal_State;

   begin
      Recursive_Construct_Processing
        (Element => The_Element,
         Control => Process_Control,
         State   => Process_State);
   end Process_Construct;

end adam.Assist.Query.find_All.element_Processing;
