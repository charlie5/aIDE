with
     aIDE,
     aIDE.Palette.of_types_package;
--       adam.a_Type.class_type;

with Ada.Text_IO;          use Ada.Text_IO;

with Glib;                 use Glib;
with Glib.Error;           use Glib.Error;
with Glib.Object;          use Glib.Object;

with Gtk.Builder;          use Gtk.Builder;
with Gtk.Button;           use Gtk.Button;
with Gtk.Handlers;

with Common_Gtk;           use Common_Gtk;
with Gtk.Window;           use Gtk.Window;
with adam.Assist;
with ada.Containers.Ordered_Sets;
with Ada.Containers.Vectors;
with Pango.Font;
with ada.Characters.handling;
with Ada.Strings.Unbounded;


package body aIDE.Palette.of_types
is

   use Adam;

   --  Recent Exceptions
   --

   package recent_Types
   is
      procedure register_Usage (the_Type : in Identifier);
      function  fetch return text_Lines;
   end recent_Types;


   package body recent_Types
   is
      type type_Usage is
         record
            Name  : Text;      -- The type name.
            Count : Natural;   -- Number of times the type has been used.
         end record;

      use type Adam.Text;

      function "<" (L, R : in type_Usage) return Boolean
      is
      begin
         return L.Name < R.Name;
      end "<";

      overriding function "=" (L, R : in type_Usage) return Boolean
      is
      begin
         return L.Name = R.Name;
      end "=";

      package type_Usage_Sets is new ada.Containers.Ordered_Sets (type_Usage);
      the_usage_Stats : type_Usage_Sets.Set;


      procedure register_Usage (the_Type : in Identifier)
      is
         use type_Usage_Sets;

         the_type_Usage : type_Usage                      := (+String (the_Type),  others => <>);
         Current        : constant type_Usage_Sets.Cursor := the_usage_Stats.find (the_type_Usage);
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


      function  fetch return text_Lines
      is
         use type_Usage_Sets,
             ada.Containers;

         the_Lines : text_Lines;

         package type_Usage_Vectors is new ada.Containers.Vectors (Positive, type_Usage);
         use     type_Usage_Vectors;

         the_usage_List : type_Usage_Vectors.Vector;

      begin
         declare
            Cursor : type_Usage_Sets.Cursor := the_usage_Stats.First;
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
            function "<" (L, R : in type_Usage) return Boolean
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

   end recent_Types;



   --  Events
   --

   procedure on_close_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                      Self       : in     aIDE.Palette.of_types.view)
   is
--        use adam.Attribute;

   begin
      Self.Top.Hide;
   end on_close_Button_clicked;


   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Palette.of_types.view);




   --  Forge
   --
   function to_types_Palette --(the_Attribute : in adam.Attribute.view;
                             -- the_Class     : in adam.Class.view)
     return View
   is
--        use adam.Attribute;

      Self        : constant Palette.of_types.view := new Palette.of_types.item;

      the_Builder :          Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;

   begin
      gtk_New (the_Builder);

      Result := the_Builder.add_from_File ("glade/palette/types_palette.glade", Error'Access);

      if Error /= null then
         Put_Line ("Error: 'adam.Palette.types.to_types_Palette' ~ " & Get_Message (Error));
         Error_Free (Error);
      end if;

      Self.Top           := gtk_Window   (the_Builder.get_Object ("top_Window"));
      Self.top_Notebook  := gtk_Notebook (the_Builder.get_Object ("top_Notebook"));
      Self.all_Notebook  := gtk_Notebook (the_Builder.get_Object ("all_Notebook"));
      Self.recent_Table  := gtk_Table    (the_Builder.get_Object ("recent_Table"));
      Self.close_Button  := gtk_Button   (the_Builder.get_Object ("close_Button"));

      Self.Top.modify_Font (Font_Desc => Pango.Font.From_String ("Courier 10"));

      Button_Callbacks.connect (Self.close_Button,
                                "clicked",
                                on_close_Button_clicked'Access,
                                Self);
      Self.freshen;

      enable_bold_Tabs_for (Self.top_Notebook);
      enable_bold_Tabs_for (Self.all_Notebook);

      return Self;
   end to_types_Palette;




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
      full_Name : constant Identifier := Identifier (package_Name & "." & Now);
   begin
      recent_Types.register_Usage (full_Name);
      Self.build_recent_List;

      Self.Invoked_by.set_Label (assist.type_button_Name_of (full_Name));
      Self.Invoked_by.set_Tooltip_Text (String (full_Name));

--        Self.Target.all := +full_Name;

--        declare
--           use type    Class.view;
--           the_Class : constant Class.view := aIDE.fetch_Class (named => package_Name);
--        begin
--           if the_Class = null then
            Self.Target.all := aIDE.the_entity_Environ.find (full_Name); -- .Name_is  (full_Name);
--              Self.Target.all.Class_is (null);
--           else
--  --              Self.Target.all.Name_is  ("");
--              Self.Target.all := a_Type.class_type.new_Type.all'Access; -- .Class_is (the_Class);
--              Self.Target.all.Class_is (the_Class);
--           end if;
--        end;

      Self.Top.hide;
   end choice_is;



   procedure show (Self : in out Item;   Invoked_by   : in     gtk.Button.gtk_Button;
                                         Target       : access adam.a_Type.view)
   is
   begin
      Self.Invoked_by := Invoked_by;
      Self.Target     := Target;

      Self.Top.show_All;
   end show;



   procedure freshen (Self : in out Item)
   is
      type a_Package;
      type Package_view is access all a_Package;

      package package_Vectors is new ada.Containers.Vectors (Positive, Package_view);
      subtype Package_vector  is package_Vectors.Vector;

      type a_Package is
         record
            Name     : Text;
            Parent   : Package_view;
            Children : Package_vector;

            Types    : adam.text_Lines;
         end record;

      the_Types : constant adam.a_Type.Vector := aIDE.the_entity_Environ.all_Types;
      Root      : aliased a_Package;


      function full_Name (the_Package : in Package_view) return String
      is
         use ada.Strings.Unbounded,
             text_Vectors;
         the_Name : Text;
         Parent   : Package_view := the_Package.Parent;
      begin
         the_Name := the_Package.Name;

         while Parent /= null
         loop
            if Parent.Parent /= null then
               insert (the_Name, 1, +Parent.Name & ".");
            end if;

            Parent := Parent.Parent;
         end loop;

         return +the_Name;
      end full_Name;


      function find_Child (Parent : in Package_view;
                           Named  : in String) return Package_view
      is
         use Adam.Assist;
         Names       : text_Lines := Split (Named);
      begin
--           put_Line ("Finding '" & Named & "' in '" & full_Name (Parent) & "'");

         for i in 1 .. Integer (Parent.Children.Length)
         loop
            declare
               use ada.Characters.handling;
               the_Child : constant Package_view := Parent.Children.Element (i);
            begin
               if to_Lower (+the_Child.Name) = to_Lower (Named) then
                  return the_Child;
               end if;
            end;
         end loop;

         return null;
      end find_Child;


      function find_Package (Parent : in Package_view;
                             Named  : in String) return Package_view
      is
         use Adam.Assist;
         Names       : text_Lines := Split (Named);
         the_Package : Package_view;
      begin
         for i in 1 .. Integer (Parent.Children.Length)
         loop
            declare
               the_Child : constant Package_view := Parent.Children.Element (i);
            begin
               if full_Name (the_Child) = Named then
                  return the_Child;
               end if;

               the_Package := find_Package (the_Child, Named);   -- Recurse.

               if the_Package /= null then
                  return the_Package;
               end if;
            end;
         end loop;

         return null;
      end find_Package;


      function demand_Package (Named : in String) return Package_view
      is
         the_Package : Package_view;
         the_Parent  : Package_view := Root'Access;

      begin
         declare
            use Adam.Assist;
            Names   : constant text_Lines := Split (Named);
            Current : Text;
         begin
            for i in 1 .. Integer (Names.Length)
            loop
--                 new_Line;
--                 put_Line ("Parent is: '" & full_Name (the_Parent) & "'");

               Current     := Names.Element (i);
               the_Package := find_Child (the_Parent, +Current);

               if the_Package = null then
                  the_Package        := new a_Package;
                  the_Package.Name   := Current;
                  the_Package.Parent := the_Parent;

--                    put_Line (+("Create package '" & the_Package.Name & "' with parent '" & full_Name (the_Parent) & "'"));

                  the_Parent.Children.append (the_Package);
               end if;

               the_Parent := the_Package;
            end loop;
         end;

         return the_Package;
      end demand_Package;

   begin
      Root.Name := +"Root";

      for i in 1 .. the_Types.Length
      loop
--           put_Line ("TYPE NAME: '" & the_Types.Element (Integer (i)).Name & "'");

         declare
            use ada.Strings,
                ada.Strings.unbounded;

            the_Type       : constant a_Type.View  := the_Types.Element (Integer (i));
            the_Type_Text  : constant Text         := +the_Type.Name;

            final_Dot      : constant Natural      := Index (the_Type_Text, ".", Backward);
            the_type_Name  : constant String       := Slice (the_Type_Text, final_Dot + 1, Length (the_Type_Text));
            package_Name   : constant String       := Slice (the_Type_Text,             1, final_Dot - 1);
            the_Package    : constant Package_view := demand_Package (package_Name);
         begin
--              new_Line;
--              put_Line ("package_Name   '" & package_Name & "'    exception_Name '" & exception_Name & "'");
--              put_Line ("package_Name   '" & full_Name (the_Package) & "'");

            the_Package.Types.Append (the_Type_Text);
         end;
      end loop;


      -- Build the Gui tree.
      --
      build_Gui_Tree:
      declare

         procedure build_Gui_for (the_Package       : in Package_view;
                                  children_Notebook : in gtk_Notebook)
         is
            the_Children              : Package_vector renames the_Package.Children;
            the_types_Palette_package : constant Palette.types_package.view
              := aIDE.Palette.types_package.to_types_Palette_package;
         begin
            --  Build the package pane.
            --
            the_types_Palette_package.Parent_is (Self'unchecked_Access);

            the_types_Palette_package.top_Widget.reparent (children_Notebook);
            children_Notebook.set_Tab_Label_Text (the_types_Palette_package.top_Widget,
                                                  +the_Package.Name);

            -- Build the types sub-pane.
            --
            for i in 1 .. Integer (the_package.Types.Length)
            loop
               the_types_Palette_package.add_Type (named        => adam.assist.Tail_of (+the_Package.Types.Element (i)),
                                                   package_Name => full_Name (the_Package));
            end loop;


            --  Build each childs Gui.
            --
            for i in 1 .. Integer (the_Children.Length)
            loop
               build_Gui_for (the_Children.Element (i),
                              the_types_Palette_package.children_Notebook);   -- Recurse.
            end loop;

            enable_bold_Tabs_for (the_types_Palette_package.children_Notebook);
         end build_Gui_for;

      begin
         while Self.all_Notebook.Get_N_Pages > 0
         loop
            Self.all_Notebook.Get_Nth_Page (0).Destroy;
         end loop;

         for i in 1 .. Integer (Root.Children.Length)
         loop
            build_Gui_for (Root.Children.Element (i),
                           Self.all_Notebook);
         end loop;

         Self.all_Notebook.Show;
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
      the_Recent : constant text_Lines := recent_Types.fetch;
      the_Button : gtk_Button;

      Row, Col   : Guint := 0;
   begin
      Self.recent_Table.Foreach (destroy_Callback'Access);

      for i in 1 .. Integer (the_Recent.Length)
      loop
         declare
            use ada.Strings.Unbounded;
            the_Type : Text renames the_Recent.Element (i);
         begin
            new_Line;
            put_Line (+("Recent: " & the_Type));
            put_Line ("   Tail: " & assist.      Tail_of (+the_Type));
            put_Line ("   Head: " & assist.strip_Tail_of (+the_Type));

--              gtk_New (the_Button, +the_Type);
            the_Button := aIDE.Palette.types_package.new_Button (Named         => assist.      Tail_of (+the_Type),
                                                                 package_Name  => assist.strip_Tail_of (+the_Type),
                                                                 types_Palette => Self'unchecked_Access,
                                                                 use_simple_Name => False);
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


end aIDE.Palette.of_types;
