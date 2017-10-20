with
     aIDE.GUI,

     glib.Error,

     gtk.Builder,
     gtk.Handlers;

with Ada.Text_IO; use Ada.Text_IO;


package body aIDE.Editor.of_record_type
is
   use Gtk.Builder,

       Glib,
       glib.Error;



--     procedure on_index_type_Button_clicked (the_Entry  : access Gtk_Button_Record'Class;
--                                             the_Editor : in     aIDE.Editor.of_record_type.view)
--     is
--     begin
--        aIDE.GUI.show_types_Palette (Invoked_by => the_Entry.all'Access,
--                                     Target     => the_Editor.Target.main_Type);
--     end on_index_type_Button_clicked;




   procedure on_rid_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                    the_Editor : in     aIDE.Editor.of_record_type.view)
   is
      pragma Unreferenced (the_Editor);
   begin
      the_Button.get_Parent.destroy;
   end on_rid_Button_clicked;



   package Entry_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Entry_Record,
                                                                            Boolean,
                                                                            AdaM.a_Type.record_type.view);

   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Editor.of_record_type.view);


   function on_unconstrained_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                            Self      : in     aIDE.Editor.of_record_type.view) return Boolean
   is
      pragma Unreferenced (the_Label);
   begin
--        Self.Target.is_Constrained;
      Self.freshen;

      return False;
   end on_unconstrained_Label_clicked;



   function on_constrained_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                          Self      : in     aIDE.Editor.of_record_type.view) return Boolean
   is
      pragma Unreferenced (the_Label);
   begin
--        Self.Target.is_Constrained (Now => False);
      Self.freshen;

      return False;
   end on_constrained_Label_clicked;


   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_record_type.view);

   package body Forge
   is
      function to_Editor (the_Target : in AdaM.a_Type.record_type.view) return View
      is
         use AdaM,
             Glib;

         Self        : constant Editor.of_record_type.view := new Editor.of_record_type.item;

         the_Builder :          Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;
         pragma Unreferenced (Result);

      begin
         Self.Target := the_Target;

         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/record_type_editor.glade", Error'Access);

         if Error /= null then
            raise Program_Error with "Error: adam.Editor.of_record_type ~ " & Get_Message (Error);
         end if;

         Self.top_Box          := gtk_Box    (the_Builder.get_Object ("top_Box"));
         Self.name_Entry       := Gtk_Entry  (the_Builder.get_Object ("name_Entry"));
         Self.        is_Label := Gtk_Label  (the_Builder.get_Object (        "is_Label"));
         Self.    record_Label := Gtk_Label  (the_Builder.get_Object (    "record_Label"));
         Self.      null_Label := Gtk_Label  (the_Builder.get_Object (      "null_Label"));
         Self.end_record_Label := Gtk_Label  (the_Builder.get_Object ("end_record_Label"));
         Self.rid_Button       := gtk_Button (the_Builder.get_Object ("rid_Button"));


         Self.name_Entry.set_Text (String (Self.Target.Name));

--           Entry_return_Callbacks.connect (Self.first_Entry,
--                                           "focus-out-event",
--                                           on_first_Entry_leave'Access,
--                                           the_Target);
--
--           Self.last_Entry.set_Text (Self.Target.Last);
--
--           Entry_return_Callbacks.connect (Self.last_Entry,
--                                           "focus-out-event",
--                                           on_last_Entry_leave'Access,
--                                           the_Target);


--           Self.type_Button.set_Label (+Self.Target.main_Type.Name);
--
--           button_Callbacks.connect (Self.type_Button,
--                                     "clicked",
--                                     on_index_type_Button_clicked'Access,
--                                     Self);


--           Button_Callbacks.Connect (Self.rid_Button,
--                                     "clicked",
--                                     on_rid_Button_clicked'Access,
--                                     Self);

--           Label_return_Callbacks.Connect (Self.unconstrained_Label,
--                                           "button-release-event",
--                                           on_unconstrained_Label_clicked'Access,
--                                           Self);
--
--           Label_return_Callbacks.Connect (Self.constrained_Label,
--                                           "button-release-event",
--                                           on_constrained_Label_clicked'Access,
--                                           Self);

         Self.freshen;

         return Self;
      end to_Editor;
   end Forge;


   procedure destroy_Callback (Widget : not null access Gtk.Widget.Gtk_Widget_Record'Class)
   is
   begin
      Widget.destroy;
   end destroy_Callback;


   overriding
   procedure freshen (Self : in out Item)
   is
      use gtk.Widget;

--        the_Literals   : AdaM.a_Type.enumeration_literal.vector renames Self.Target.Literals;
--        literal_Editor : aIDE.Editor.of_enumeration_literal.view;
   begin
      null;

--        if Self.is_in_unconstrained_Array
--        then
--           Self.unconstrained_Label.show;
--
--           Self.first_Entry.hide;
--           Self.last_Entry.hide;
--           Self.range_Label.show;
--           Self.  constrained_Label.hide;
--        else
--           Self.unconstrained_Label.hide;
--        end if;

--        if Self.is_in_unconstrained_Array
--        then
--           Self.unconstrained_Label.show;
--
--           Self.first_Entry.hide;
--           Self.last_Entry.hide;
--           Self.range_Label.show;
--           Self.  constrained_Label.hide;
--        else
--           Self.unconstrained_Label.hide;
--
--           if Self.Target.is_Constrained
--           then
--              Self.range_Label.show;
--              Self.  constrained_Label.show;
--              Self.first_Entry.show;
--              Self.last_Entry.show;
--           else
--              Self.range_Label.hide;
--              Self.first_Entry.hide;
--              Self.last_Entry.hide;
--              Self.  constrained_Label.hide;
--              Self.unconstrained_Label.hide;
--           end if;
--        end if;


--        Self.first_Entry.set_Text (Self.Target.First);
--        Self.last_Entry .set_Text (Self.Target.Last);
--        Self.literals_Box.Foreach (destroy_Callback'Access);

--        for Each of the_Literals
--        loop
--           literal_Editor := Editor.of_enumeration_literal.Forge.to_Editor (Each,
--                                                                            targets_Parent => Self.Target.all'Access);
--           Self.literals_Box.pack_Start (literal_Editor.top_Widget);
--        end loop;
   end freshen;



   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.top_Box);
   end top_Widget;


end aIDE.Editor.of_record_type;
