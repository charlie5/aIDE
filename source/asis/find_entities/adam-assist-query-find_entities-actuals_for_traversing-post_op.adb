with AdaM.Assist.Query.find_Entities.Metrics,
     AdaM.Entity;

with Ada.Wide_Text_IO;
with Ada.Text_IO;
with Ada.Characters.Handling;
with Ada.Exceptions;

with Asis.Exceptions;
with Asis.Errors;
with Asis.Implementation,
     asis.Elements;


separate (AdaM.Assist.Query.find_Entities.Actuals_for_traversing)

procedure Post_Op
  (Element :        Asis.Element;
   Control : in out Asis.Traverse_Control;
   State   : in out Traversal_State)
is
   pragma Unreferenced (Control);
   use Asis, asis.Elements;
   use type AdaM.Entity.view;

   the_Declaration : constant asis.Declaration       := asis.Declaration (Element);
   the_Kind        : constant Asis.Declaration_Kinds := asis.Elements.Declaration_Kind (the_Declaration);

begin
   if Is_Nil (State.ignore_Starter)
   then
      State.parent_Stack.delete_Last;   -- Children no longer need to know their parent.

      if Metrics.current_Parent.Parent /= null
      then
         ada.Text_IO.put_Line ("Raising Metrics.current_Parent from " & Metrics.current_Parent.Name &
                                 " to " & Metrics.current_Parent.Parent.Name);
      else
         ada.Text_IO.put_Line ("Raising Metrics.current_Parent from " & Metrics.current_Parent.Name &
                                 " to null");
      end if;

      Metrics.current_Parent := Metrics.current_Parent.Parent;
      ada.Text_IO.new_Line;

   else
      if Is_Equal (Element, State.ignore_Starter)
      then
         State.ignore_Starter := Nil_Element;
      end if;
   end if;


   if the_Kind = Asis.A_Package_Declaration
   then
      if not Metrics.current_Packages.Is_Empty
      then
         Metrics.current_Packages.delete_Last;     -- Pop the current package stack.
      end if;
   end if;


exception

   when Ex : Asis.Exceptions.ASIS_Inappropriate_Context          |
             Asis.Exceptions.ASIS_Inappropriate_Container        |
             Asis.Exceptions.ASIS_Inappropriate_Compilation_Unit |
             Asis.Exceptions.ASIS_Inappropriate_Element          |
             Asis.Exceptions.ASIS_Inappropriate_Line             |
             Asis.Exceptions.ASIS_Inappropriate_Line_Number      |
             Asis.Exceptions.ASIS_Failed                         =>

      Ada.Wide_Text_IO.Put ("Post_Op : ASIS exception (");

      Ada.Wide_Text_IO.Put (Ada.Characters.Handling.To_Wide_String (
              Ada.Exceptions.Exception_Name (Ex)));

      Ada.Wide_Text_IO.Put (") is raised");
      Ada.Wide_Text_IO.New_Line;

      Ada.Wide_Text_IO.Put ("ASIS Error Status is ");

      Ada.Wide_Text_IO.Put
        (Asis.Errors.Error_Kinds'Wide_Image (Asis.Implementation.Status));

      Ada.Wide_Text_IO.New_Line;

      Ada.Wide_Text_IO.Put ("ASIS Diagnosis is ");
      Ada.Wide_Text_IO.New_Line;
      Ada.Wide_Text_IO.Put (Asis.Implementation.Diagnosis);
      Ada.Wide_Text_IO.New_Line;

      Asis.Implementation.Set_Status;

   when Ex : others =>

      Ada.Wide_Text_IO.Put ("Post_Op : ");

      Ada.Wide_Text_IO.Put (Ada.Characters.Handling.To_Wide_String (
              Ada.Exceptions.Exception_Name (Ex)));

      Ada.Wide_Text_IO.Put (" is raised (");

      Ada.Wide_Text_IO.Put (Ada.Characters.Handling.To_Wide_String (
              Ada.Exceptions.Exception_Information (Ex)));

      Ada.Wide_Text_IO.Put (")");
      Ada.Wide_Text_IO.New_Line;

end Post_Op;
