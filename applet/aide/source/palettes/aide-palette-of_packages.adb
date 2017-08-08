with
     aIDE,
     aIDE.Palette.of_packages_subpackages,
--       AdaM.a_Package,
     AdaM.Environment,
     AdaM.Assist,

     Glib,
     Glib.Error,
     Glib.Object,

     Gtk.Builder,
     Gtk.Handlers,
     Gtk.Label,

     Pango.Font,
     Common_Gtk,

     Ada.Containers.Ordered_Sets,
     Ada.Containers.Vectors;

with Ada.Text_IO;   use Ada.Text_IO;


package body aIDE.Palette.of_packages
is
   use Glib,
       Glib.Error,
       Glib.Object,

       Gtk.Builder,
       Gtk.Button,
       Gtk.GEntry,

       Common_Gtk,
       Gtk.Window;


   --  Recent Packages - ToDo: Refactor this out, if possible.
   --

   package body recent_Packages
   is
      type package_Usage is
         record
            the_Package : AdaM.a_Package.view;
            Name        : AdaM.Text;      -- The package name.
            Count       : Natural;        -- Number of times the package has been used.
         end record;

      function "<" (L, R : in package_Usage) return Boolean
      is
         use type AdaM.Text;
      begin
         return L.Name < R.Name;
      end "<";

      overriding function "=" (L, R : in package_Usage) return Boolean
      is
         use type AdaM.Text;
      begin
         return L.Name = R.Name;
      end "=";

      package package_Usage_Sets is new ada.Containers.Ordered_Sets (package_Usage);
      the_usage_Stats : package_Usage_Sets.Set;


      procedure register_Usage (package_Name : in AdaM.Text;
                                the_Package  : in AdaM.a_Package.view)
      is
         use package_Usage_Sets;

         the_type_Usage : package_Usage             := (the_Package, package_Name,  others => <>);
         Current        : constant package_Usage_Sets.Cursor := the_usage_Stats.find (the_type_Usage);
      begin
         if Current /= No_Element
         then
            the_type_Usage.Count := Element (Current).Count + 1;
            the_usage_Stats.replace_Element (Current, the_type_Usage);
         else
            the_type_Usage.Count := 1;
            the_usage_Stats.insert (the_type_Usage);
         end if;
      end register_Usage;




      procedure register_Usage (the_Package : in AdaM.a_Package.view)
      is
         use package_Usage_Sets;

         the_type_Usage :          package_Usage             := (the_Package,  others => <>);
         Current        : constant package_Usage_Sets.Cursor := the_usage_Stats.find (the_type_Usage);
      begin
         if Current /= No_Element
         then
            the_type_Usage.Count := Element (Current).Count + 1;
            the_usage_Stats.replace_Element (Current, the_type_Usage);
         else
            the_type_Usage.Count := 1;
            the_usage_Stats.insert (the_type_Usage);
         end if;
      end register_Usage;



      function  fetch return AdaM.a_Package.vector
      is
         use package_Usage_Sets,
             ada.Containers;

--           the_Lines : AdaM.text_Lines;
         the_Packages : AdaM.a_Package.vector;

         package type_Usage_Vectors is new ada.Containers.Vectors (Positive, package_Usage);
         use     type_Usage_Vectors;

         the_usage_List : type_Usage_Vectors.Vector;

      begin
         declare
            Cursor : package_Usage_Sets.Cursor := the_usage_Stats.First;
         begin
            while has_Element (Cursor)
            loop
               if Element (Cursor).Count > 0 then
                  the_usage_List.append (Element (Cursor));
               end if;

               exit when the_Packages.Length = 25;     -- Limit results to 25 entries.
               next (Cursor);
            end loop;
         end;

         declare
            function "<" (L, R : in package_Usage) return Boolean
            is
            begin
               return L.Count > R.Count;
            end "<";

            package Sorter is new type_Usage_Vectors.Generic_Sorting ("<");
         begin
            Sorter.sort (the_usage_List);
         end;

         declare
            Cursor : type_Usage_Vectors.Cursor := the_usage_List.First;
         begin
            while has_Element (Cursor)
            loop
               if Element (Cursor).Count > 0
               then
                  the_Packages.append (Element (Cursor).the_Package);
               end if;

               next (Cursor);
            end loop;
         end;

         return the_Packages;
      end fetch;





      function  fetch return AdaM.text_Lines
      is
         use package_Usage_Sets,
             ada.Containers;

         the_Lines : AdaM.text_Lines;

         package type_Usage_Vectors is new ada.Containers.Vectors (Positive, package_Usage);
         use     type_Usage_Vectors;

         the_usage_List : type_Usage_Vectors.Vector;

      begin
         declare
            Cursor : package_Usage_Sets.Cursor := the_usage_Stats.First;
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
            function "<" (L, R : in package_Usage) return Boolean
            is
            begin
               return L.Count > R.Count;
            end "<";

            package Sorter is new type_Usage_Vectors.Generic_Sorting ("<");
         begin
            Sorter.sort (the_usage_List);
         end;

         declare
            Cursor : type_Usage_Vectors.Cursor := the_usage_List.First;
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


      procedure read  (From : access Ada.Streams.Root_Stream_Type'Class)
      is
      begin
         package_Usage_Sets.Set'read (From, the_usage_Stats);
      end read;


      procedure write (To   : access Ada.Streams.Root_Stream_Type'Class)
      is
      begin
         package_Usage_Sets.Set'write (To, the_usage_Stats);
      end write;

   end recent_Packages;



   ----------
   --  Events
   --

   procedure on_ok_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                   Self       : in     aIDE.Palette.of_packages.view)
   is
      pragma Unreferenced (the_Button);
   begin
      Self.choice_is (Self.new_package_Entry.get_Text, null);
      Self.Top.hide;
   end on_ok_Button_clicked;


   procedure on_close_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                      Self       : in     aIDE.Palette.of_packages.view)
   is
      pragma Unreferenced (the_Button);
   begin
      Self.Top.hide;
   end on_close_Button_clicked;


   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Palette.of_packages.view);

   use gtk.Label;

   type label_Info is
      record
         package_Name : AdaM.Text;
         Palette      : aIDE.Palette.of_packages.view;
         the_Package  : Adam.a_Package.view;
      end record;



   function on_tab_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                  Info      : in     label_Info) return Boolean
   is
      use AdaM,
          gtk.Widget;

      Self         :          aIDE.Palette.of_packages.view renames Info.Palette;

      the_Notebook : constant gtk_Notebook := gtk_Notebook (the_Label.Get_Parent);
      the_page_Num :          gInt;

   begin
      for i in 0 .. the_Notebook.Get_N_Pages - 1
      loop
         if the_Notebook.get_tab_Label (the_Notebook.Get_Nth_Page (i)) = gtk_Widget (the_Label)
         then
            the_page_Num := i;
         end if;
      end loop;

      if the_page_Num = the_Notebook.get_current_Page
      then
         Self.choice_is (+Info.package_Name, Info.the_Package);
         Self.Top.hide;
      else
         the_Notebook.set_current_Page (the_page_Num);
      end if;

      return False;
   end on_tab_Label_clicked;


   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                            Boolean,
                                                                            label_Info);
   ---------
   --  Forge
   --
   function to_packages_Palette return View
   is
      Self        : constant Palette.of_packages.view := new Palette.of_packages.item;

      the_Builder :          Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;
      pragma Unreferenced (Result);

   begin
      gtk_New (the_Builder);

      Result := the_Builder.add_from_File ("glade/palette/packages_palette.glade", Error'Access);

      if Error /= null
      then
         Put_Line ("Error: 'adam.Palette.packages.to_packages_Palette' ~ " & Get_Message (Error));
         Error_Free (Error);
      end if;

      Self.Top               := gtk_Window   (the_Builder.get_Object ("top_Window"));
      Self.top_Notebook      := gtk_Notebook (the_Builder.get_Object ("top_Notebook"));
      Self.all_Notebook      := gtk_Notebook (the_Builder.get_Object ("all_Notebook"));
      Self.recent_Table      := gtk_Table    (the_Builder.get_Object ("recent_Table"));
      Self.close_Button      := gtk_Button   (the_Builder.get_Object ("close_Button"));
      Self.ok_Button         := gtk_Button   (the_Builder.get_Object ("ok_Button"));
      Self.new_package_Entry := gtk_Entry    (the_Builder.get_Object ("new_package_Entry"));

      Self.Top.modify_Font (Font_Desc => Pango.Font.From_String ("Courier 10"));

      Button_Callbacks.connect (Self.ok_Button,
                                "clicked",
                                on_ok_Button_clicked'Access,
                                Self);

      Button_Callbacks.connect (Self.close_Button,
                                "clicked",
                                on_close_Button_clicked'Access,
                                Self);
      Self.freshen;

      enable_bold_Tabs_for (Self.top_Notebook);
      enable_bold_Tabs_for (Self.all_Notebook);

      return Self;
   end to_packages_Palette;



   --  Attributes
   --

   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.Top);
   end top_Widget;



   --  Operations
   --

   procedure choice_is (Self : in out Item;   package_Name : in String;
                                              the_Package  : in AdaM.a_Package.view)
   is
      use AdaM,
          AdaM.Assist;

      full_Name : constant String := package_Name;
   begin
      recent_Packages.register_Usage (+full_Name, the_Package);
      Self.build_recent_List;

      if Self.Invoked_by /= null
      then
         put_Line ("HHHHHHHHHHHHHHHH  " & the_Package.full_Name);
--           Self.Invoked_by.set_Label (full_Name);
         Self.Invoked_by.set_Label        (identifier_Suffix (the_Package.full_Name, 2));
         Self.Invoked_by.set_Tooltip_Text (the_Package.full_Name);
      end if;

      Self.Target.Name_is  (full_Name);
      Self.Target.Package_is (the_Package.all'Access);

      Self.Top.hide;
   end choice_is;



   procedure show (Self : in out Item;   Invoked_by   : in     Gtk.Button.gtk_Button;
                                         Target       : in     AdaM.context_Line.view)
   is
   begin
      Self.Invoked_by := Invoked_by;
      Self.Target     := Target;

      Self.Top.show_All;
   end show;



   procedure freshen (Self : in out Item)
   is
      use AdaM;

--        the_Environ : AdaM.Environment.Item renames aIDE.the_Environ;

   begin
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
            the_Children                 :          AdaM.a_Package.Vector renames the_Package.child_Packages;
            the_packages_Palette_package : constant Palette.of_packages_subpackages.view
              := aIDE.Palette.of_packages_subpackages.to_packages_Palette_package;
         begin
            --  Build the package pane.
            --
            the_packages_Palette_package.Parent_is (Self'unchecked_Access);

            the_packages_Palette_package.top_Widget.reparent (children_Notebook);
            children_Notebook.set_Tab_Label_Text (the_packages_Palette_package.top_Widget,
                                                  the_Package.Name);
            put_Line ("PACKAGE NAME ZZZZZZZZZZZ   " & the_Package.Name);
            -- Configure event handling.
            --
            declare
               use gtk.Label;
               the_tab_Label : constant gtk_Label
                 := gtk_Label (children_Notebook.get_tab_Label (the_packages_Palette_package.top_Widget));
            begin
               the_tab_Label.set_Selectable (True);
               label_return_Callbacks.connect (the_tab_Label,
                                               "button-release-event",
                                               on_tab_Label_clicked'Access,
                                               (package_name => +the_Package.Name,
                                                palette      => Self'unchecked_Access,
                                                the_Package  => the_Package));
            end;

            --  Build each childs Gui.
            --
            for i in 1 .. Integer (the_Children.Length)
            loop
               build_Gui_for (the_Children.Element (i),
                              the_packages_Palette_package.children_Notebook);   -- Recurse.
            end loop;

            the_packages_Palette_package.children_Notebook.Popup_enable;
            enable_bold_Tabs_for (the_packages_Palette_package.children_Notebook);
         end build_Gui_for;


      begin
         -- Recursively add sub-gui's for each package, rooted at 'Standard'.
         --
         for i in 1 .. Integer (a_Package.item (the_entity_Environ.standard_Package.all).child_Packages.Length)
         loop
            put_Line ("Building GUI for '" & the_entity_Environ.standard_Package.child_Packages.Element (i).Name & "'");
            build_Gui_for (the_entity_Environ.standard_Package.child_Packages.Element (i),
                           Self.all_Notebook);
         end loop;

         Self.all_Notebook.Popup_enable;
         Self.all_Notebook.Show_All;
      end build_Gui_Tree;

      Self.build_recent_List;
   end freshen;



   procedure destroy_Callback (Widget : not null access Gtk.Widget.Gtk_Widget_Record'Class)
   is
   begin
      Widget.destroy;
   end destroy_Callback;



   procedure build_recent_List (Self : in out Item)
   is
--        the_Recent : constant AdaM.text_Lines := recent_Packages.fetch;
      the_Recent : constant AdaM.a_Package.vector := recent_Packages.fetch;
      the_Button : gtk_Button;

      Row, Col   : Guint := 0;
   begin
      Self.recent_Table.Foreach (destroy_Callback'Access);

      for i in 1 .. Integer (the_Recent.Length)
      loop
         declare
            use AdaM;
            the_Package : AdaM.a_Package.view renames the_Recent.Element (i);
         begin
            the_Button := aIDE.Palette.of_packages_subpackages.new_Button (for_Package      => the_Package,
                                                                           Named            => the_Package.Name,
                                                                           packages_Palette => Self'unchecked_Access);
            Self.recent_Table.attach (the_Button,
                                      Col, Col + 1,
                                      Row, Row + 1,
                                      Xoptions => 0,
                                      Yoptions => 0);
            the_Button.show_All;

            if Row = 6
            then
               Row := 0;
               Col := Col + 1;
            else
               Row := Row + 1;
            end if;
         end;
      end loop;
   end build_recent_List;


end aIDE.Palette.of_packages;
