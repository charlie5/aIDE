with Ada.Text_IO;          use Ada.Text_IO;

with Glib;                 use Glib;
with Glib.Error;           use Glib.Error;
with Glib.Object;          use Glib.Object;

with Gtk.Box;              use Gtk.Box;
with Gtk.Builder;          use Gtk.Builder;
with Gtk.Button;           use Gtk.Button;
with Gtk.Frame;            use Gtk.Frame;
with Gtk.Handlers;
with adam.Assist;


package body aIDE.Palette.of_exceptions_subpackages
is
   use Adam;

   type button_Info is
      record
         package_Name  : Text;
         Self          : aIDE.Palette.of_exceptions.view;
         the_Exception : AdaM.Declaration.of_exception.view;
      end record;


   procedure on_exception_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                          the_Info   : in     button_Info)
   is
      the_exception_Name : constant String := assist.Tail_of (the_Button.Get_Label);
   begin
      the_Info.Self.choice_is (the_exception_Name,
                               +the_Info.package_Name,
                               the_Info.the_Exception);
   end on_exception_Button_clicked;


   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               button_Info);



   --  Forge
   --
   function to_exceptions_Palette_package return View
   is
      Self        : constant Palette.of_exceptions_subpackages.view := new Palette.of_exceptions_subpackages.item;

      the_Builder : Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;

   begin
      Gtk_New (the_Builder);

      Result := the_Builder.Add_From_File ("glade/palette/exception_palette-subpackages.glade", Error'Access);

      if Error /= null then
         raise Program_Error with "Error: 'aIDE.Palette.of_exceptions_subpackages.to_exceptions_Palette_package' ~ "
                                & Get_Message (Error);
      end if;

      Self.Top               := gtk_Frame    (the_Builder.get_Object ("top_Frame"));
      Self.children_Notebook := gtk_Notebook (the_Builder.get_Object ("children_Notebook"));
      Self.exceptions_Box    := gtk_Box      (the_Builder.get_Object ("exceptions_Box"));

      --           enable_bold_Tabs_for (Self.children_Notebook);

      return Self;
   end to_exceptions_Palette_package;



   function new_Button (Named              : in String;
                        package_Name       : in String;
                        exceptions_Palette : in palette.of_exceptions.view;
                        use_simple_Name    : in Boolean) return gtk.Button.gtk_Button
   is
      full_Name  : constant String    := package_Name & "." & Named;
      the_Button : gtk_Button;
   begin
      if use_simple_Name then
         gtk_New (the_Button, Named);
      else
         gtk_New (the_Button, assist.type_button_Name_of (full_Name));
      end if;

      the_Button.Set_Tooltip_Text (full_Name);

      Button_Callbacks.connect (the_Button,
                                "clicked",
                                on_exception_Button_clicked'Access,
                                (+package_Name,
                                 exceptions_Palette,
                                 null));
      return the_Button;
   end new_Button;



   function new_Button (Named              : in String;
                        package_Name       : in String;
                        exceptions_Palette : in palette.of_exceptions.view;
                        use_simple_Name    : in Boolean;
                        the_Exception      : in AdaM.Declaration.of_exception.view) return gtk.Button.gtk_Button
   is
      full_Name  : constant String    := package_Name & "." & Named;
      the_Button : gtk_Button;
   begin
      if use_simple_Name then
         gtk_New (the_Button, Named);
      else
         gtk_New (the_Button, assist.type_button_Name_of (full_Name));
      end if;

      the_Button.Set_Tooltip_Text (full_Name);

      Button_Callbacks.connect (the_Button,
                                "clicked",
                                on_exception_Button_clicked'Access,
                                (+package_Name,
                                 exceptions_Palette,
                                 the_Exception));
      return the_Button;
   end new_Button;



   --  Attributes
   --

   procedure Parent_is (Self : in out Item;   Now : in aIDE.Palette.of_exceptions.view)
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



   --  Operations
   --

   procedure add_Exception (Self : access Item;   Named        : in String;
                                                  package_Name : in String)
   is
      the_Button : constant gtk_Button := new_Button (Named,
                                                      package_Name,
                                                      Self.Parent,
                                                      use_simple_Name => True);
   begin
--        gtk_New (the_Button, Named);
--
--        Button_Callbacks.connect (the_Button,
--                                  "clicked",
--                                  on_exception_Button_clicked'Access,
--                                  (+package_Name,
--                                    Self.Parent));

      Self.exceptions_Box.pack_Start (the_Button);
   end add_Exception;




   procedure add_Exception (Self : access Item;   the_Exception : in AdaM.Declaration.of_exception.view;
                                                  the_Package   : in AdaM.a_Package.view)
   is
      the_Button : constant gtk_Button := new_Button (the_Exception.Name,
                                                      the_Package.Name,     -- "", --the_Exception.package_Name,
                                                      Self.Parent,
                                                      use_simple_Name => True,
                                                      the_Exception   => the_Exception);
   begin
--        gtk_New (the_Button, Named);
--
--        Button_Callbacks.connect (the_Button,
--                                  "clicked",
--                                  on_exception_Button_clicked'Access,
--                                  (+package_Name,
--                                    Self.Parent));

      Self.exceptions_Box.pack_Start (the_Button);
   end add_Exception;



end aIDE.Palette.of_exceptions_subpackages;
