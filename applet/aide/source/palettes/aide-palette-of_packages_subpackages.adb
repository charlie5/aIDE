with
     Glib,
     Glib.Error,
     Glib.Object,

     Gtk.Builder,
     Gtk.Handlers;

with Ada.Text_IO;          use Ada.Text_IO;


package body aIDE.Palette.of_packages_subpackages
is

   use Glib,
       Glib.Error,
       Glib.Object,

       Gtk.Box,
       Gtk.Builder,
       Gtk.Button,
       Gtk.Frame;


   type button_Info is
      record
         package_Name     : AdaM.Text;
         packages_Palette : aIDE.Palette.of_packages.view;
      end record;


   procedure on_select_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                       the_Info   : in     button_Info)
   is
      use AdaM;
   begin
      the_Info.packages_Palette.choice_is (+the_Info.package_Name);
   end on_select_Button_clicked;


   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               button_Info);

   --  Forge
   --
   function to_packages_Palette_package return View
   is
      Self        : constant Palette.of_packages_subpackages.view := new Palette.of_packages_subpackages.item;

      the_Builder :          Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;

   begin
      Gtk_New (the_Builder);

      Result := the_Builder.Add_From_File ("glade/palette/packages_palette-subpackages.glade", Error'Access);

      if Error /= null
      then
         Put_Line ("Error: 'adam.Palette.of_packages_subpackages.to_packages_Palette_package' ~ " & Get_Message (Error));
         Error_Free (Error);
      end if;

      Self.Top               := gtk_Frame    (the_Builder.get_Object ("top_Frame"));
      Self.select_button_Box := gtk_Box      (the_Builder.get_Object ("select_button_Box"));
      Self.children_Notebook := gtk_Notebook (the_Builder.get_Object ("children_Notebook"));

      return Self;
   end to_packages_Palette_package;



   function new_Button (Named            : in String;
                        packages_Palette : in palette.of_packages.view) return gtk_Button
   is
      use AdaM;
      the_Button : gtk_Button;
   begin
      gtk_New (the_Button, Named);

      Button_Callbacks.connect (the_Button,
                                "clicked",
                                on_select_Button_clicked'Access,
                                (+Named,
                                 packages_Palette));
      return the_Button;
   end new_Button;




   --  Attributes
   --

   procedure Parent_is (Self : in out Item;   Now : in aIDE.Palette.of_packages.view)
   is
   begin
      Self.Parent := Now;
   end Parent_is;



   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.Top);
   end top_Widget;



   function children_Notebook (Self : in Item) return gtk_Notebook
   is
   begin
      return Self.children_Notebook;
   end children_Notebook;


end aIDE.Palette.of_packages_subpackages;
