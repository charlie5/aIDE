with
     aIDE.Palette.of_packages,
     aIDE.Editor,
     AdaM.Entity,
     AdaM.context_Line,
     AdaM.exception_Handler,
--       AdaM.Source,
     gtk.Button;


package aIDE.GUI
is

   procedure open;

   procedure clear_Log;
   procedure log (the_Message : in String   := "";
                  Count       : in Positive := 1);

   procedure show_packages_Palette (Invoked_by : in     Gtk.Button.gtk_Button;
                                    Target     : in     AdaM.context_Line.view);

--     procedure show_source_entities_Palette (Invoked_by : in aIDE.Editor.view;
--                                             Target     : in AdaM.Source.Entities_view);

   procedure show_source_entities_Palette (Invoked_by : in aIDE.Editor.view;
                                           Target     : in AdaM.Entity.Entities_view);

   procedure show_exceptions_Palette (Invoked_by : in Gtk.Button.gtk_Button;
                                      Target     : in adam.exception_Handler.view;
                                      Slot       : in Positive);

   the_packages_Palette   : aIDE.Palette.of_packages.view;

end aIDE.GUI;
