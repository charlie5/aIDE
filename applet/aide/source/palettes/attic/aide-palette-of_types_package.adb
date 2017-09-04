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


package body aIDE.Palette.of_types_package
is
   use Adam;

   type button_Info is
      record
         package_Name  : Text;
         types_Palette : aIDE.Palette.types.view;
      end record;


   procedure on_type_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                     the_Info   : in     button_Info)
   is
      the_type_Name : constant String := the_Button.Get_Label;
   begin
      the_Info.types_Palette.choice_is (assist.Tail_of (the_type_Name),
                                        +the_Info.package_Name);
   end on_type_Button_clicked;


   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               button_Info);



   --  Forge
   --
   function to_types_Palette_package return View
   is
      Self        : constant Palette.types_package.view := new Palette.types_package.item;

      the_Builder : Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;

   begin
      Gtk_New (the_Builder);

      Result := the_Builder.Add_From_File ("glade/palette/types_palette-package.glade", Error'Access);

      if Error /= null then
         Put_Line ("Error: 'adam.Palette.types_package.to_types_Palette_package' ~ " & Get_Message (Error));
         Error_Free (Error);
      end if;

      Self.Top               := gtk_Frame    (the_Builder.get_Object ("top_Frame"));
      Self.children_Notebook := gtk_Notebook (the_Builder.get_Object ("children_Notebook"));
      Self.types_Box         := gtk_Box      (the_Builder.get_Object ("types_Box"));
      Self.types_Window      := Gtk_Scrolled_Window (the_Builder.get_Object ("types_Window"));

      --           enable_bold_Tabs_for (Self.children_Notebook);

--        self.types_Window.Hide;
      self.types_Window.Show_all;
      self.types_Window.Show_now;

      return Self;
   end to_types_Palette_package;



   function new_Button (Named           : in String;
                        package_Name    : in String;
                        types_Palette   : in palette.types.view;
                        use_simple_Name : in Boolean) return gtk_Button
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
                                on_type_Button_clicked'Access,
                                (+package_Name,
                                 types_Palette));
      return the_Button;
   end new_Button;




   --  Attributes
   --

   procedure Parent_is (Self : in out Item;   Now : in aIDE.Palette.types.view)
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

   procedure add_Type (Self : access Item;   Named        : in String;
                                             package_Name : in String)
   is
      the_Button : constant gtk_Button := new_Button (Named,
                                                      package_Name,
                                                      Self.Parent,
                                                      use_simple_Name => True);
   begin
--        Button_Callbacks.connect (the_Button,
--                                  "clicked",
--                                  on_type_Button_clicked'Access,
--                                  (+package_Name,
--                                   adam.Palette.types.view (Self.Parent)));

      Self.types_Box.pack_Start (the_Button,
                                 Expand  => False,
                                 Fill    => False,
                                 Padding => 1);

--        self.types_Window.Hide;
--        Self.types_Box.Hide;
      self.types_Window.Show_all;
      self.types_Window.Show_now;

   end add_Type;


end aIDE.Palette.of_types_package;
