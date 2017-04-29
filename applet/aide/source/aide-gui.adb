with
     Common_Gtk,
     Glib,
     Glib.Error,

     Gtk.Main,
     Gtk.Builder,
     Gtk.Button,
     Gtk.Text_View,
     Gtk.Tree_View,
     Gtk.Widget,
     Gtk.Window,
     Gtk.Alignment,
     Gtk.Notebook,
     Gtk.Tree_Store,
     Gtk.Tree_Selection,
     Gtk.Text_Iter,

     Pango.Font,

     ada.Characters.latin_1,
     ada.Text_IO;


package body aIDE.GUI
is
   use Glib,
       Glib.Error,
       gtk.Button,
       gtk.Builder,
       gtk.Text_View,
       gtk.Tree_View,
       gtk.Window,
       gtk.Alignment,
       gtk.Notebook,
       gtk.Tree_Store,
       Pango.Font;


   -- Main Widgets
   --
   top_Window       : Gtk_Window;
   the_top_Notebook : Gtk_Notebook;


   -- 'App' Notebook Page Widgets
   --

   new_app_Button    : Gtk_Button;
   rid_app_Button    : Gtk_Button;

   the_app_tree_Store     : gtk_tree_Store;
   the_app_tree_View      : gtk_tree_View;
   the_app_tree_Selection : Gtk.Tree_Selection.gtk_Tree_Selection;

   the_app_Alignment : Gtk_Alignment;


   -- Builder Widgets
   --
   build_project_Button   : Gtk_Button;
   the_build_log_Textview : Gtk_Text_View;


   --  Gui Events
   --

   procedure on_build_project_Button_clicked (Button : access Gtk_Button_Record'Class)
   is
      pragma Unreferenced (Button);
   begin
      aIDE.build_Project;
   end on_build_project_Button_clicked;



   procedure destroy (Widget : access gtk.Widget.Gtk_Widget_Record'Class)
   is
      pragma Unreferenced (Widget);
   begin
      Gtk.Main.Main_Quit;
   end Destroy;



   procedure open
   is
      use Common_Gtk,
          ada.Text_IO;

      glade_Builder : Gtk_Builder;
      Result        : Guint;         pragma Unreferenced (Result);
   begin
      Gtk.Main.Init;

      Gtk_New (glade_Builder);

      --  Read in our Glade XML files.
      --
      declare
         use ada.Text_IO;

         Error : aliased GError;
      begin
         Result := glade_Builder.Add_From_File ("glade/adam.glade",
                                                Error'Access);
         if Error /= null
         then
            put_Line (  "Error adding 'adam.glade' to Glade builder: "
                        & Get_Message (Error));
            Error_Free (Error);
         end if;
      end;

      -- Set our references to each important widget.
      --
      top_Window       := Gtk_Window   (glade_Builder.Get_Object ("top_Window"));
      the_top_Notebook := Gtk_Notebook (glade_Builder.Get_Object ("top_Notebook"));

      the_app_Alignment      := gtk_Alignment  (glade_Builder.Get_Object ("app_editor_Alignment"));
      new_app_Button         := gtk_Button     (glade_Builder.Get_Object ("new_app_Button"));
      rid_app_Button         := gtk_Button     (glade_Builder.Get_Object ("rid_app_Button"));
      the_app_tree_Store     := gtk_tree_Store (glade_Builder.Get_Object ("app_tree_Store"));
      the_app_tree_View      := gtk_tree_View  (glade_Builder.Get_Object ("app_tree_View"));
      the_app_tree_Selection := the_app_tree_View.Get_Selection;

      build_project_Button   := gtk_Button    (glade_Builder.Get_Object ("build_project_Button"));
      the_build_log_Textview := gtk_Text_view (glade_Builder.Get_Object ("builder_log_Textview"));

      top_Window.Modify_Font (Font_Desc => From_String ("Courier 10"));

      log ("Welcome... ");

      Widget_Handler.connect (top_Window,
                              "destroy",
                              Widget_Handler.To_Marshaller (Destroy'Access));

      Button_Handler.connect (build_project_Button,
                              "clicked",
                              on_build_project_Button_clicked'Access);

      top_Window.show;     -- Display our main window and all of its children.
      enable_bold_Tabs_for (the_top_Notebook);

      gtk.Main.main;       -- Enter main GtkAda event loop.
   end open;



   --  Logging
   --

   procedure clear_Log
   is
      First,
      Last : gtk.text_Iter.gtk_text_Iter;
   begin
      the_build_log_Textview.get_Buffer.get_start_Iter (First);
      the_build_log_Textview.get_Buffer.get_end_Iter   (Last);

      the_build_log_Textview.get_Buffer.delete (First, Last);
   end clear_Log;



   procedure log (the_Message : in String   := "";
                  Count       : in Positive := 1)
   is
      use Ada.Characters;

      Status : Boolean;   pragma Unreferenced (Status);
      Iter   : Gtk.Text_Iter.gtk_text_Iter;

      use type glib.Gint;
   begin
      for i in 1 .. Count
      loop
         the_build_log_Textview.get_Buffer.insert_at_Cursor (the_Message & Latin_1.LF);
      end loop;

      while gtk.Main.Events_Pending
      loop
         Status := gtk.Main.Main_Iteration;
      end loop;

      the_build_log_Textview.Get_Buffer.Get_Iter_At_Offset (Iter, -1);
      Status := the_build_log_Textview.Scroll_To_Iter (Iter          => Iter,
                                                       Within_Margin => 0.1,
                                                       Use_Align     => True,
                                                       Xalign        => 0.2,
                                                       Yalign        => 0.3);
   end log;


end aIDE.GUI;
