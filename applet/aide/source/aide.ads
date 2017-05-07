with
     adam.Subprogram,
     adam.Environment;

package aIDE
is

   procedure start;
   procedure stop;


private
   the_Environ      : adam.Environment.item;

   all_Apps         : adam.Subprogram.vector;
   the_selected_App : adam.Subprogram.view;

   procedure build_Project;
end aIDE;
