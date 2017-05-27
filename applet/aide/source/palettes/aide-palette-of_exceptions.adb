with aIDE.Palette.of_exceptions_subpackages;

with Ada.Text_IO;          use Ada.Text_IO;

with Glib;                 use Glib;
with Glib.Error;           use Glib.Error;
with Glib.Object;          use Glib.Object;

with Gtk.Builder;          use Gtk.Builder;
with Gtk.Button;           use Gtk.Button;
with Gtk.Handlers,
     Gtk.Label;

with Common_Gtk;           use Common_Gtk;
with Gtk.Window;           use Gtk.Window;
with adam.Assist;
with ada.Containers.Ordered_Sets;
with Ada.Containers.Vectors;
with ada.Strings.Unbounded;
with AdaM.a_Package;


package body aIDE.Palette.of_exceptions
is

   --  Recent Exceptions
   --

   package recent_Exceptions
   is
      procedure register_Usage (the_Exception : in adam.Text);
      function  fetch return adam.text_Lines;
   end recent_Exceptions;


   package body recent_Exceptions
   is
      type exception_Usage is
         record
            Name  : adam.Text;
            Count : Natural;
         end record;

      function "<" (L, R : in exception_Usage) return Boolean
      is
         use type adam.Text;
      begin
         return L.Name < R.Name;
      end "<";

      overriding function "=" (L, R : in exception_Usage) return Boolean
      is
         use type adam.Text;
      begin
         return L.Name = R.Name;
      end "=";

      package exception_Usage_Sets is new ada.Containers.Ordered_Sets (exception_Usage);
      the_usage_Stats : exception_Usage_Sets.Set;


      procedure register_Usage (the_Exception : in adam.Text)
      is
         use exception_Usage_Sets;

         the_exception_Usage : exception_Usage             := (the_Exception,  others => <>);
         Current             : constant exception_Usage_Sets.Cursor := the_usage_Stats.find (the_exception_Usage);
      begin
         if Current /= No_Element
         then
            the_exception_Usage.Count := Element (Current).Count + 1;
            the_usage_Stats.replace_Element (Current, the_exception_Usage);
         else
            the_exception_Usage.Count := 1;
            the_usage_Stats.insert (the_exception_Usage);
         end if;
      end register_Usage;


      function  fetch return adam.text_Lines
      is
         use exception_Usage_Sets,
             ada.Containers;

         the_Lines : adam.text_Lines;

         package exception_Usage_Vectors is new ada.Containers.Vectors (Positive, exception_Usage);
         use     exception_Usage_Vectors;

         the_usage_List : exception_Usage_Vectors.Vector;

      begin
         declare
            Cursor : exception_Usage_Sets.Cursor := the_usage_Stats.First;
         begin
            while has_Element (Cursor)
            loop
               if Element (Cursor).Count > 0 then
                  the_usage_List.append (Element (Cursor));
               end if;

               exit when the_Lines.Length = 25;
               next (Cursor);
            end loop;
         end;

         declare
            function "<" (L, R : in exception_Usage) return Boolean
            is
            begin
               return L.Count > R.Count;
            end "<";

            package Sorter is new exception_Usage_Vectors.Generic_Sorting ("<");
         begin
            Sorter.sort (the_usage_List);
         end;

         declare
            Cursor : exception_Usage_Vectors.Cursor := the_usage_List.First;
         begin
            while has_Element (Cursor)
            loop
               if Element (Cursor).Count > 0 then
                  the_Lines.Append (Element (Cursor).Name);
               end if;

               exit when the_Lines.Length = 25;
               next (Cursor);
            end loop;
         end;

         return the_Lines;
      end fetch;

   end recent_Exceptions;



   --  Events
   --

   procedure on_delete_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                       Self       : in     aIDE.Palette.of_exceptions.view)
   is
      the_Label : String := the_Button.Get_Label;
   begin
      Self.Invoked_by.hide;
      Self.Target.exception_Name_is (Self.Slot, "free");

      Self.Top.hide;
   end on_delete_Button_clicked;



   procedure on_close_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                      Self       : in     aIDE.Palette.of_exceptions.view)
   is
   begin
      Self.Top.Hide;
   end on_close_Button_clicked;



   use gtk.Label;

   type label_Info is
      record
         package_Name : AdaM.Text;
         Palette      : aIDE.Palette.of_exceptions.view;
      end record;


   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Palette.of_exceptions.view);

   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (gtk.Label.Gtk_Label_Record,
                                                                            Boolean,
                                                                            label_Info);



   --  Forge
   --
   function to_exceptions_Palette return View
   is
      Self        : constant Palette.of_exceptions.view := new Palette.of_exceptions.item;

      the_Builder :          Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;

   begin
      gtk_New (the_Builder);

      Result := the_Builder.add_from_File ("glade/palette/exception_palette.glade", Error'Access);

      if Error /= null then
         raise program_Error with "Error: 'adam.Palette.exceptions.to_exceptions_Palette' ~ " & Get_Message (Error);
      end if;

      Self.Top           := gtk_Window   (the_Builder.get_Object ("top_Window"));
      Self.top_Notebook  := gtk_Notebook (the_Builder.get_Object ("top_Notebook"));
      Self.all_Notebook  := gtk_Notebook (the_Builder.get_Object ("all_Notebook"));
      Self.recent_Table  := gtk_Table    (the_Builder.get_Object ("recent_Table"));
      Self.delete_Button := gtk_Button   (the_Builder.get_Object ("delete_Button"));
      Self.close_Button  := gtk_Button   (the_Builder.get_Object ("close_Button"));

      Button_Callbacks.connect (Self.delete_Button,
                                "clicked",
                                on_delete_Button_clicked'Access,
                                Self);

      Button_Callbacks.connect (Self.close_Button,
                                "clicked",
                                on_close_Button_clicked'Access,
                                Self);
      Self.freshen;

      enable_bold_Tabs_for (Self.top_Notebook);
      enable_bold_Tabs_for (Self.all_Notebook);

      return Self;
   end to_exceptions_Palette;




   --  Attributes
   --

   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.Top);
   end top_Widget;



   --  Operations
   --

   procedure choice_is (Self : in out Item;   Now          : in String;
                                              package_Name : in String)
   is
      use adam;
      full_Name : constant String := package_Name & "." & Now;
   begin
      recent_Exceptions.register_Usage (+full_Name);
      Self.build_recent_List;

      Self.Invoked_by.Set_Label (Now);
      Self.Invoked_by.Set_Tooltip_Text (full_Name);

      Self.Target.exception_Name_is (Self.Slot, full_Name);

      Self.Top.hide;
   end choice_is;



   procedure show (Self : in out Item;   Invoked_by : in gtk_Button;
                                         Target     : in adam.exception_Handler.view;
                                         Slot       : in Positive)
   is
   begin
      Self.Invoked_by := Invoked_by;
      Self.Target     := Target;
      Self.Slot       := Slot;

      Self.Top.show_All;
   end show;



   procedure freshen (Self : in out Item)
   is
      use Adam;

--        type a_Package;
--        type Package_view is access all a_Package;
--
--        package package_Vectors is new ada.Containers.Vectors (Positive, Package_view);
--        subtype Package_vector  is package_Vectors.Vector;
--
--        type a_Package is
--           record
--              Name     : adam.Text;
--              Parent   : Package_view;
--              Children : Package_vector;
--
--              Exceptions : adam.text_Lines;
--           end record;

--        the_Exceptions : constant adam.text_Lines := adam.Assist.known_Exceptions;
--        Root           : aliased a_Package;

   begin
--        Root.Name := +"Root";


      -- Clear out old notebook pages.
      --
      while Self.all_Notebook.Get_N_Pages > 0
      loop
         Self.all_Notebook.Get_Nth_Page (0).Destroy;
      end loop;


      -- Build the Gui tree.
      --
      build_Gui_Tree:
      declare

         procedure build_Gui_for (the_Package       : in AdaM.a_Package.view;
                                  children_Notebook : in gtk_Notebook)
         is
            the_Children                   :          AdaM.a_Package.Vector renames the_Package.child_Packages;
            the_exceptions_Palette_package : constant Palette.of_exceptions_subpackages.view
              := aIDE.Palette.of_exceptions_subpackages.to_exceptions_Palette_package;
         begin
            --  Build the package pane.
            --
            the_exceptions_Palette_package.Parent_is (Self'unchecked_Access);

            the_exceptions_Palette_package.top_Widget.Reparent (children_Notebook);
            children_Notebook.set_Tab_Label_Text (the_exceptions_Palette_package.top_Widget,
                                                  the_Package.Name);

            -- Build the exceptions sub-pane.
            --
            for Each of the_Package.all_Exceptions
            loop
               the_exceptions_Palette_package.add_Exception (named        => Each.Name,
                                                             package_Name => the_Package.Name);
--                                                               package_Name => full_Name (the_Package));
            end loop;

            -- Configure event handling.
            --
--              declare
--                 use gtk.Label;
--                 the_tab_Label : constant gtk_Label
--                   := gtk_Label (children_Notebook.get_tab_Label (the_exceptions_Palette_package.top_Widget));
--              begin
--                 the_tab_Label.set_Selectable (True);
--                 label_return_Callbacks.connect (the_tab_Label,
--                                                 "button-release-event",
--                                                 on_tab_Label_clicked'Access,
--                                                 (package_name => the_Package.Name,
--                                                  palette      => Self'unchecked_Access));
--              end;

            --  Build each childs Gui.
            --
            for i in 1 .. Integer (the_Children.Length)
            loop
               build_Gui_for (the_Children.Element (i),
                              the_exceptions_Palette_package.children_Notebook);   -- Recurse.
            end loop;

            enable_bold_Tabs_for (the_exceptions_Palette_package.children_Notebook);
         end build_Gui_for;

      begin
         -- Recursively add sub-gui's for each package, rooted at 'Standard'.
         --
--           for i in 1 .. Integer (the_Environ.standard_Package.Children.Length)
--           loop
--              build_Gui_for (the_Environ.standard_Package.child_Packages.Element (i).all'Access,
--                             Self.all_Notebook);
--           end loop;

--           for i in 1 .. Integer (the_entity_Environ.standard_Package.child_Packages.Length)
--           loop
--              build_Gui_for (the_Environ.standard_Package.child_Packages.Element (i).all'Access,
--                             Self.all_Notebook);
--           end loop;

         build_Gui_for (the_entity_Environ.standard_Package,
                        Self.all_Notebook);

         Self.all_Notebook.Popup_enable;
         Self.all_Notebook.Show_All;
      end build_Gui_Tree;

      Self.build_recent_List;   -- todo: This is useless til usage stats are made persistent.
   end freshen;



   procedure destroy_Callback (Widget : not null access Gtk.Widget.Gtk_Widget_Record'Class)
   is
   begin
      Widget.destroy;
   end destroy_Callback;



   procedure build_recent_List (Self : in out Item)
   is
      the_Recent : constant adam.text_Lines := recent_Exceptions.fetch;
      the_Button : gtk_Button;

      Row, Col   : Guint := 0;
   begin
      Self.recent_Table.Foreach (destroy_Callback'Access);

      for i in 1 .. Integer (the_Recent.Length)
      loop
         declare
            use adam,
                ada.Strings.Unbounded;
            the_Exception : adam.Text renames the_Recent.Element (i);
         begin
            put_Line (+("Recent: " & the_Exception));

--              gtk_New (the_Button, +the_Exception);
            the_Button := aIDE.Palette.of_exceptions_subpackages.new_Button
                             (Named              => assist.      Tail_of (+the_Exception),
                              package_Name       => assist.strip_Tail_of (+the_Exception),
                              exceptions_Palette => Self'unchecked_Access,
                              use_simple_Name    => False);

            Self.recent_Table.attach (the_Button,
                                      Col, Col + 1,
                                      Row, Row + 1,
                                      Xoptions => 0,
                                      Yoptions => 0);
            the_Button.show_All;

            if Row = 6 then
               Row := 0;
               Col := Col + 1;
            else
               Row := Row + 1;
            end if;
         end;
      end loop;
   end build_recent_List;


end aIDE.Palette.of_exceptions;
