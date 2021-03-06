with
     aIDE.Editor.of_subprogram,
     aIDE.Editor.of_block,
     aIDE.Editor.of_package,
     aIDE.Editor.of_pragma,
     aIDE.Palette.of_source_Entities,
     aIDE.Palette.of_pragmas,
     aIDE.Palette.of_exceptions,
     aIDE.Palette.of_types,

     adaM.a_Pragma,

     Common_Gtk,
     Glib,
     Glib.Error,

     Gtk.Main,
     Gtk.Builder,
     Gtk.Text_View,
     Gtk.Tree_View,
     Gtk.Tree_Model,
     Gtk.Widget,
     Gtk.Window,
     Gtk.Alignment,
     Gtk.Notebook,
     Gtk.Tree_Store,
     Gtk.Tree_Selection,
     Gtk.Text_Iter,
     Gtk.Handlers,

     Pango.Font,

     ada.Characters.latin_1,
     ada.Text_IO;
with Ada.Text_IO;
with Ada.Tags;


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


   --  Editors
   --
   the_app_Editor     : aIDE.Editor.of_subprogram.view;
   the_package_Editor : aIDE.Editor.of_Package.view;


   -- Palettes
   --
   the_source_entities_Palette : aIDE.Palette.of_source_entities.view;
   the_pragma_Palette          : aIDE.Palette.of_pragmas.view;
   the_exceptions_Palette      : aIDE.Palette.of_exceptions.view;
   the_types_Palette           : aIDE.Palette.of_types.view;


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



   -- Package Tab Widgets
   --

   choose_package_Button : Gtk_Button;
   new_package_Button    : Gtk_Button;
   rid_package_Button    : Gtk_Button;

   the_package_tree_Store     : gtk_tree_Store;
   the_package_tree_View      : gtk_tree_View;
   the_package_tree_Selection : Gtk.Tree_Selection.gtk_Tree_Selection;

   the_package_Alignment : Gtk_Alignment;





   -- Gui Callbacks
   --

   package tree_selection_Handlers
   is new Gtk.Handlers.Callback (Widget_Type => Gtk.Tree_Selection.Gtk_Tree_Selection_Record);


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



   procedure on_new_app_Button_clicked (Button : access Gtk_Button_Record'Class)
   is
      pragma Unreferenced (Button);
      the_new_App : constant adam.Subprogram.view := adam.Subprogram.new_Subprogram (Name => anonymous_Procedure);
   begin
      all_Apps.append              (the_new_App);
      the_app_Editor.Target_is (the_new_App);

      declare
         use AdaM,
             Gtk,
             Gtk.Tree_Model;

         Iter   :          gtk_tree_Iter;
         Parent : constant gtk_tree_Iter := Null_Iter;
      begin
         the_app_tree_Store.append          (Iter, Parent);
         the_app_tree_Store.set             (Iter, 0, +the_new_App.Name);
         the_app_tree_Selection.select_Iter (Iter);
      end;
   end on_new_app_Button_clicked;


   procedure on_rid_app_Button_clicked (Button : access Gtk_Button_Record'Class)
   is
      pragma Unreferenced (Button);

      use Gtk,
          Gtk.Tree_Model;

      use type adam.Subprogram.view;

      the_App : constant adam.Subprogram.view := the_app_Editor.Target;

      Iter      : gtk_tree_Iter;
      the_Model : Gtk_Tree_Model;
   begin
      if the_App = the_selected_App then
         return;
      end if;

      the_app_tree_Selection.get_Selected (the_Model, Iter);
      the_app_tree_Store.remove (Iter);

      the_app_tree_Selection.select_Iter  (the_app_tree_Store.get_Iter_first);

      all_Apps.delete (all_Apps.find_Index (the_App));
   end on_rid_app_Button_clicked;


   procedure on_app_Selection_changed (Selection : access Gtk.Tree_Selection.Gtk_Tree_Selection_Record'Class)
   is
      use AdaM,
          gtk.Tree_Model,
          ada.Text_IO;
      Iter      : Gtk_Tree_Iter;
      the_model : Gtk_Tree_Model;
   begin
      Selection.Get_Selected (the_model, Iter);

      if Iter /= null_Iter
      then
         declare
            app_Name : constant String := gtk.Tree_Model.Get_String (the_model, Iter, 0);
         begin
            the_app_Editor.Target_is (fetch_App (+app_Name));
         end;
      end if;
   end on_app_Selection_changed;




   procedure on_choose_package_Button_clicked (Button : access Gtk_Button_Record'Class)
   is
      pragma Unreferenced (Button);
   begin
      Ada.Text_IO.put_Line ("YAY");
      show_packages_Palette (Invoked_by => Button.all'Access,
                             Target     => the_applet_Package);
   end on_choose_package_Button_clicked;




   procedure open
   is
      use Common_Gtk,
          ada.Text_IO;

      glade_Builder : Gtk_Builder;
      Result        : Guint;         pragma Unreferenced (Result);
   begin
--        put_Line ("************************************************");
--        put_Line ("'" & Duration'Image (Duration'Delta) & "'");


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

      -- Hide unused pages in the top notebook.
      --
      the_top_Notebook.get_Nth_Page (0).hide;
--        the_top_Notebook.get_Nth_Page (2).hide;
      the_top_Notebook.get_Nth_Page (3).hide;
      the_top_Notebook.get_Nth_Page (4).hide;



      log ("Welcome... ");

      Widget_Handler.connect (top_Window,
                              "destroy",
                              Widget_Handler.To_Marshaller (Destroy'Access));

      Button_Handler.connect (build_project_Button,
                              "clicked",
                              on_build_project_Button_clicked'Access);

      Button_Handler.Connect (new_app_Button,
                              "clicked",
                              on_new_app_Button_clicked'Access);

      Button_Handler.Connect (rid_app_Button,
                              "clicked",
                              on_rid_app_Button_clicked'Access);


      the_app_Editor := aIDE.Editor.of_subprogram.Forge.to_subprogram_Editor (the_selected_App);
      the_app_Editor.top_Widget.Reparent (New_Parent => the_app_Alignment);

      for Each of all_Apps
      loop
         declare
            use AdaM,
                Gtk.Tree_Model;
            use type AdaM.Subprogram.view;

            Iter   :          gtk_tree_Iter;
            Parent : constant gtk_tree_Iter := Null_Iter;
         begin
            the_app_tree_Store.append (Iter, Parent);
            the_app_tree_Store.set    (Iter, 0, +Each.Name);

            if Each = all_Apps.first_Element
            then
               the_app_tree_Selection.Select_Iter (Iter);
            end if;
         end;
      end loop;

      the_app_tree_View.show_All;
      tree_selection_Handlers.connect (the_app_tree_Selection,
                                       "changed",
                                       on_app_Selection_changed'Access);


      top_Window.show;     -- Display our main window and all of its children.
      enable_bold_Tabs_for (the_top_Notebook);

      -- The Package Editor
      --

      the_package_Alignment      := Gtk_Alignment  (glade_Builder.Get_Object ("package_editor_Alignment"));
      choose_package_Button      := Gtk_Button     (glade_Builder.Get_Object ("choose_package_Button"));
      new_package_Button         := Gtk_Button     (glade_Builder.Get_Object ("new_package_Button"));
      rid_package_Button         := Gtk_Button     (glade_Builder.Get_Object ("rid_package_Button"));
      the_package_tree_Store     := gtk_tree_Store (glade_Builder.Get_Object ("package_tree_Store"));
      the_package_tree_View      := gtk_tree_View  (glade_Builder.Get_Object ("package_tree_View"));
      the_package_tree_Selection := the_package_tree_View.Get_Selection;

      Button_Handler.connect (choose_package_Button,
                              "clicked",
                              on_choose_package_Button_clicked'Access);


      -- The Palettes
      --

      the_packages_Palette        := aIDE.Palette.of_packages.to_packages_Palette;
      the_source_entities_Palette := aIDE.Palette.of_source_entities.to_source_entities_Palette;
      the_pragma_Palette          := aIDE.Palette.of_pragmas.to_source_entities_Palette;
      the_exceptions_Palette      := aIDE.Palette.of_exceptions.to_exceptions_Palette;
      the_types_Palette           := aIDE.Palette.of_types.to_Palette;


      the_package_Editor := aIDE.Editor.of_package.Forge.to_package_Editor (the_applet_Package);
      the_package_Editor.top_Widget.Reparent (New_Parent => the_package_Alignment);


      gtk.Main.main;       -- Enter main GtkAda event loop.
   end open;




   -- Palettes
   --

   procedure show_packages_Palette (Invoked_by : in     Gtk.Button.gtk_Button;
                                    Target     : in     AdaM.context_Line.view)
   is
   begin
      the_packages_Palette.show (Invoked_by, Target);
   end show_packages_Palette;



   procedure show_packages_Palette (Invoked_by : in     Gtk.Button.gtk_Button;
                                    Target     : in     AdaM.a_Package.view)
   is
   begin
      the_packages_Palette.show (Invoked_by, Target);
   end show_packages_Palette;



   procedure show_types_Palette (Invoked_by : in     Gtk.Button.gtk_Button;
                                 Target     : access AdaM.a_Type.view)
   is
   begin
      the_types_Palette.show (Invoked_by, Target);
   end show_types_Palette;






   procedure show_source_entities_Palette (Invoked_by : in aIDE.Editor.view;
                                           Target     : in AdaM.Entity.Entities_view)
--                                             Target     : in AdaM.Source.Entities_view)
   is
      use Palette.of_source_entities;
--        use type adam.Source.Entities_View;
      use type adam.Entity.Entities_view,
               Ada.Tags.Tag;

--        the_Editor : constant AIDE.Editor.of_block.view        := AIDE.Editor.of_block.view (Invoked_by);
      the_Editor :          aIDE.Editor.of_block.view;
      the_Filter :          Palette.of_source_entities.Filter;
   begin
      Ada.Text_IO.put_Line ("EDITOR TAG " & ada.tags.External_Tag (Invoked_by.all'Tag));
      Ada.Text_IO.put_Line ("EDITOR TAG " & ada.tags.External_Tag (aide.Editor.of_block.item'Tag));

      if Invoked_by.all in aide.Editor.of_block.item'Class
      then
         the_Editor := AIDE.Editor.of_block.view (Invoked_by);

         if the_Editor.Target.my_Declarations = Target
         then
            the_Filter := declare_Region;

         elsif the_Editor.Target.my_Statements = Target
         then
            the_Filter := begin_Region;

         else
            raise Program_Error;
         end if;

      elsif Invoked_by.all in aide.Editor.of_package.item'Class
      then
--           the_Editor := AIDE.Editor.of_package.view (Invoked_by);
         the_Filter := declare_Region;

      else
         raise Program_Error with ada.tags.External_Tag (Invoked_by.all'Tag) & " not yet supported.";
      end if;

      the_source_entities_Palette.show (Invoked_by, Target, the_Filter);
   end show_source_entities_Palette;



   procedure show_pragma_Palette (Invoked_by : in aIDE.Editor.view;
                                  Target     : in AdaM.a_Pragma.view)
   is
   begin
      the_pragma_Palette.show (Invoked_by, Target, aIDE.Palette.of_pragmas.declare_Region);
   end show_pragma_Palette;




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



   procedure show_exceptions_Palette (Invoked_by : in gtk_Button;
                                      Target     : in adam.exception_Handler.view;
                                      Slot       : in Positive)
   is
   begin
      the_exceptions_Palette.show (Invoked_by, Target, Slot);
   end show_exceptions_Palette;



   procedure update_selected_package_Name (new_Name : in String)
   is
   begin
      choose_package_Button.set_Label (new_Name);
   end update_selected_package_Name;


--     procedure update_selected_package_Name (new_Name : in String)
--     is
--        use gtk.Tree_Model, ada.Text_IO;
--
--        the_Selection : Gtk_Tree_Iter;
--        the_Model     : Gtk_Tree_Model;
--     begin
--        the_package_tree_Selection.get_Selected (the_Model, the_Selection);
--
--        if the_Selection /= null_Iter
--        then
--           declare
--  --              use ada.Characters.handling,
--  --                  ada.Directories;
--
--              old_Name : constant String := gtk.Tree_Model.get_String (the_Model, the_Selection, 0);
--           begin
--              if new_Name /= old_Name
--              then
--                 the_package_tree_Store.set (the_Selection, 0, new_Name);
--  --                 build_Package;
--              end if;
--           end;
--        else
--           put_Line ("update_selected_package_Name : *** Null Iter ***");
--        end if;
--     end update_selected_package_Name;



   procedure set_selected_Package (To : in AdaM.a_Package.view)
   is
   begin
      the_package_Editor.Package_is (To);
   end set_selected_Package;



end aIDE.GUI;
