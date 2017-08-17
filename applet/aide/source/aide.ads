private
with
     AdaM.Subprogram,
     AdaM.a_Package,
     AdaM.Environment;


package aIDE
is

   procedure start;
   procedure stop;


private
--     the_Environ      : AdaM.Environment.item;

   all_Apps         : AdaM.Subprogram.vector;
   the_selected_App : AdaM.Subprogram.view;

   procedure build_Project;

   function  fetch_App (Named : in AdaM.Identifier) return adam.Subprogram.view;


   anonymous_Procedure : constant String := "Anon";


   the_applet_Package : adam.a_Package.view;



   the_entity_Environ : AdaM.Environment.item;


end aIDE;
