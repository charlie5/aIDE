with
     Gtk.Container,
     Gtk.Style_Provider,
     Gtk.Style_Context,
     Gtk.Css_Provider,
     Glib.Error,
     Glib,
     Ada.Text_IO;


package body aIDE.Style
is

   use Gtk.Style_Provider,
       Gtk.Style_Context,
       Gtk.Css_Provider,
       Ada.Text_IO,
       Gtk.Container;

   Provider : Gtk_Css_Provider;


   procedure define
   is
      Error : aliased Glib.Error.GError;
   begin
      Provider := Gtk_Css_Provider_New;

      if not Provider.Load_From_Path ("./css_accordion.css", Error'Access)
      then
         Put_Line ("Failed to load css_accordion.css !");
         Put_Line (Glib.Error.Get_Message (Error));
         return;
      end if;
   end define;



   procedure Apply_Css_recursive (Widget   : not null access Gtk.Widget.Gtk_Widget_Record'Class;
                                  Provider :                 Gtk_Style_Provider)
   is
      package FA is new Forall_User_Data (Gtk_Style_Provider);
   begin
      Get_Style_Context (Widget).Add_Provider (Provider, Glib.Guint'Last);

      if Widget.all in Gtk_Container_Record'Class
      then
         declare
            Container : constant Gtk_Container := Gtk_Container (Widget);
         begin
            FA.Forall (Container, Apply_Css_recursive'Unrestricted_Access, Provider);
         end;
      end if;
   end Apply_Css_recursive;



   procedure apply_CSS (Widget : not null access Gtk.Widget.Gtk_Widget_Record'Class)
   is
   begin
      Apply_Css_recursive (Widget, +Provider);
   end apply_CSS;


end aIDE.Style;
