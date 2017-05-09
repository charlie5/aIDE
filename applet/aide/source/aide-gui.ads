with
     aIDE.Palette.of_packages,
     aIDE.Editor,
     AdaM.context_Line,
     AdaM.Source,
     gtk.Button;


package aIDE.GUI
is

   procedure open;

   procedure clear_Log;
   procedure log (the_Message : in String   := "";
                  Count       : in Positive := 1);

   procedure show_packages_Palette (Invoked_by : in     Gtk.Button.gtk_Button;
                                    Target     : in     AdaM.context_Line.view);

   procedure show_source_entities_Palette (Invoked_by : in aIDE.Editor.view;
                                           Target     : in AdaM.Source.Entities_view);


   the_packages_Palette   : aIDE.Palette.of_packages.view;

end aIDE.GUI;
