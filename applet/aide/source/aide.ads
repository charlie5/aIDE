with
     AdaM.Subprogram,
     AdaM.Environment;

package aIDE
is

   procedure start;
   procedure stop;


private
   the_Environ      : AdaM.Environment.item;

   all_Apps         : AdaM.Subprogram.vector;
   the_selected_App : AdaM.Subprogram.view;

   procedure build_Project;

   function  fetch_App (Named : in String) return adam.Subprogram.view;

end aIDE;
