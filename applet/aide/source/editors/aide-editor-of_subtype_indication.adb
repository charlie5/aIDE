with
     aIDE.GUI,
     aIDE.Editor.of_enumeration_literal,
     AdaM.a_Type.enumeration_literal,

     glib.Error,

     gtk.Builder,
     gtk.Handlers;
with Ada.Text_IO; use Ada.Text_IO;


package body aIDE.Editor.of_subtype_indication
is
   use Gtk.Builder,

       Glib,
       glib.Error;



   function on_first_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                  Target    : in     AdaM.subtype_Indication.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.First_is (the_Text);
      return False;
   end on_first_Entry_leave;


   function on_last_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                 Target    : in     AdaM.subtype_Indication.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.Last_is (the_Text);
      return False;
   end on_last_Entry_leave;


   procedure on_index_type_Button_clicked (the_Entry  : access Gtk_Button_Record'Class;
                                           the_Editor : in     aIDE.Editor.of_subtype_Indication.view)
   is
   begin
      aIDE.GUI.show_types_Palette (Invoked_by => the_Entry.all'Access,
                                   Target     => the_Editor.Target.main_Type);
   end on_index_type_Button_clicked;




   procedure on_rid_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                    the_Editor : in     aIDE.Editor.of_subtype_Indication.view)
   is
      pragma Unreferenced (the_Editor);
   begin
      the_Button.get_Parent.destroy;
   end on_rid_Button_clicked;



   package Entry_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Entry_Record,
                                                                            Boolean,
                                                                            AdaM.subtype_Indication.view);

   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Editor.of_subtype_Indication.view);


   function on_unconstrained_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                            Self      : in     aIDE.Editor.of_subtype_Indication.view) return Boolean
   is
      pragma Unreferenced (the_Label);
   begin
--        Self.Target.is_Constrained;
      Self.freshen;

      return False;
   end on_unconstrained_Label_clicked;



   function on_constrained_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                          Self      : in     aIDE.Editor.of_subtype_Indication.view) return Boolean
   is
      pragma Unreferenced (the_Label);
   begin
--        Self.Target.is_Constrained (Now => False);
      Self.freshen;

      return False;
   end on_constrained_Label_clicked;


   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_subtype_Indication.view);

   package body Forge
   is
      function to_Editor (the_Target                : in AdaM.subtype_Indication.view;
                          is_in_unconstrained_Array : in Boolean) return View
      is
         use AdaM,
             Glib;

         Self        : constant Editor.of_subtype_Indication.view := new Editor.of_subtype_Indication.item;

         the_Builder :          Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;
         pragma Unreferenced (Result);

      begin
         Self.Target                    := the_Target;
         Self.is_in_unconstrained_Array := is_in_unconstrained_Array;

         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/subtype_indication_editor.glade", Error'Access);

         if Error /= null then
            raise Program_Error with "Error: adam.Editor.of_enumeration_type ~ " & Get_Message (Error);
         end if;

         Self.top_Box             := gtk_Box    (the_Builder.get_Object ("top_Box"));
         Self.type_Button         := Gtk_Button (the_Builder.get_Object ("index_type_Button"));

         Self.range_Label         := Gtk_Label (the_Builder.get_Object ("range_Label"));
         Self.unconstrained_Label := Gtk_Label (the_Builder.get_Object ("unconstrained_Label"));
         Self.  constrained_Label := Gtk_Label (the_Builder.get_Object (  "constrained_Label"));

         Self.first_Entry         := Gtk_Entry  (the_Builder.get_Object ("first_Entry"));
         Self. last_Entry         := Gtk_Entry  (the_Builder.get_Object ( "last_Entry"));
--           Self.rid_Button          := gtk_Button (the_Builder.get_Object ("rid_Button"));


         Self.first_Entry.set_Text (Self.Target.First);

         Entry_return_Callbacks.connect (Self.first_Entry,
                                         "focus-out-event",
                                         on_first_Entry_leave'Access,
                                         the_Target);

         Self.last_Entry.set_Text (Self.Target.Last);

         Entry_return_Callbacks.connect (Self.last_Entry,
                                         "focus-out-event",
                                         on_last_Entry_leave'Access,
                                         the_Target);


         Self.type_Button.set_Label (+Self.Target.main_Type.Name);

         button_Callbacks.connect (Self.type_Button,
                                   "clicked",
                                   on_index_type_Button_clicked'Access,
                                   Self);


--           Button_Callbacks.Connect (Self.rid_Button,
--                                     "clicked",
--                                     on_rid_Button_clicked'Access,
--                                     Self);

         Label_return_Callbacks.Connect (Self.unconstrained_Label,
                                         "button-release-event",
                                         on_unconstrained_Label_clicked'Access,
                                         Self);

         Label_return_Callbacks.Connect (Self.constrained_Label,
                                         "button-release-event",
                                         on_constrained_Label_clicked'Access,
                                         Self);

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

      if Self.Target.is_Constrained
      then
         if Self.Target.First = ""
         then
            Self.range_Label.hide;
            Self.  constrained_Label.hide;
            Self.unconstrained_Label.hide;
            Self.first_Entry.hide;
            Self.last_Entry.hide;
         else
            Self.range_Label.show;
            Self.  constrained_Label.show;
            Self.unconstrained_Label.hide;
            Self.first_Entry.show;
            Self.last_Entry.show;
         end if;
      else
         Self.range_Label.show;
         Self.first_Entry.hide;
         Self.last_Entry.hide;
         Self.  constrained_Label.hide;
         Self.unconstrained_Label.show;
      end if;
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


end aIDE.Editor.of_subtype_indication;
