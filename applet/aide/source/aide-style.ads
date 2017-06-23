with
     Gtk.Widget;


package aIDE.Style
is

   procedure define;
   procedure apply_CSS (Widget : not null access Gtk.Widget.Gtk_Widget_Record'Class);

end aIDE.Style;
