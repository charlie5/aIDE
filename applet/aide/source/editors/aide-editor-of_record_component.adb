with
     aIDE.GUI,

     glib.Error,

     gtk.Builder,
     gtk.Handlers;

with Ada.Text_IO; use Ada.Text_IO;


package body aIDE.Editor.of_record_component
is
   use Gtk.Builder,

       Glib,
       glib.Error;


   function on_name_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                      Target    : in     AdaM.record_Component.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.Name_is (AdaM.Identifier (the_Text));
      return False;
   end on_name_Entry_leave;



   function on_initialiser_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                        Target    : in     AdaM.record_Component.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.Default_is (the_Text);
      return False;
   end on_initialiser_Entry_leave;



   procedure on_type_Button_clicked (the_Entry  : access Gtk_Button_Record'Class;
                                     the_Editor : in     aIDE.Editor.of_record_component.view)
   is
   begin
      aIDE.GUI.show_types_Palette (Invoked_by => the_Entry.all'Access,
                                   Target     => the_Editor.Target.Definition.subtype_Indication.main_Type);
   end on_type_Button_clicked;



   procedure on_rid_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                    the_Editor : in     aIDE.Editor.of_record_component.view)
   is
      pragma Unreferenced (the_Editor);
   begin
      the_Button.get_Parent.destroy;
   end on_rid_Button_clicked;



   package Entry_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Entry_Record,
                                                                            Boolean,
                                                                            AdaM.record_Component.view);

   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Editor.of_record_component.view);


   function on_colon_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                    Self      : in     aIDE.Editor.of_record_component.view) return Boolean
   is
      pragma Unreferenced (the_Label);
   begin
--        if    not Self.Target.is_Aliased
--        then
--           Self.Target.is_Aliased  (now => True);
--
--        elsif     Self.Target.is_Aliased
--        then
--           Self.Target.is_Aliased  (now => False);
--
--        elsif not Self.Target.is_Aliased
--        then
--           Self.Target.is_Aliased  (now => True);
--
--        elsif     Self.Target.is_Aliased
--        then
--           Self.Target.is_Aliased  (now => False);
--
--        else
--           raise Program_Error;
--        end if;

      put_Line ("YAY");
      Self.freshen;

      return False;
   end on_colon_Label_clicked;



   function on_initialiser_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                          Self      : in     aIDE.Editor.of_record_component.view) return Boolean
   is
      pragma Unreferenced (the_Label);
   begin
      put_Line ("YAY2");
--        Self.Target.is_Constrained (Now => False);
      Self.freshen;

      return False;
   end on_initialiser_Label_clicked;


   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_record_component.view);

   package body Forge
   is
      function new_Editor (the_Target : in AdaM.record_Component.view) return View
      is
         use AdaM,
             Glib;

         Self        : constant Editor.of_record_component.view := new Editor.of_record_component.item;

         the_Builder :          Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;
         pragma Unreferenced (Result);

      begin
         Self.Target := the_Target;

         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/record_component_editor.glade", Error'Access);

         if Error /= null then
            raise Program_Error with "Error: adam.Editor.of_object_type ~ " & Get_Message (Error);
         end if;

         Self.top_Box           := gtk_Box    (the_Builder.get_Object ("top_Box"));
         Self.name_Entry        := Gtk_Entry  (the_Builder.get_Object ("name_Entry"));
         Self.type_Button       := Gtk_Button (the_Builder.get_Object ("type_Button"));

         Self.   colon_Label    := Gtk_Label (the_Builder.get_Object ("colon_Label"));
         Self. aliased_Label    := Gtk_Label (the_Builder.get_Object ("aliased_Label"));

         Self.initializer_Label := Gtk_Label  (the_Builder.get_Object ("initializer_Label"));
         Self.default_Entry := Gtk_Entry  (the_Builder.get_Object ("initializer_Entry"));

         Self.rid_Button        := gtk_Button (the_Builder.get_Object ("rid_Button"));


         Self.name_Entry.Set_Text (+Self.Target.Name);

         Entry_return_Callbacks.connect (Self.name_Entry,
                                         "focus-out-event",
                                         on_name_Entry_leave'Access,
                                         the_Target);

         Self.default_Entry.set_Text (Self.Target.Default);

         Entry_return_Callbacks.connect (Self.default_Entry,
                                         "focus-out-event",
                                         on_initialiser_Entry_leave'Access,
                                         the_Target);

         Self.type_Button.set_Label (+Self.Target.Definition.subtype_Indication.main_Type.Name);

         button_Callbacks.connect (Self.type_Button,
                                   "clicked",
                                   on_type_Button_clicked'Access,
                                   Self);

         Button_Callbacks.Connect (Self.rid_Button,
                                   "clicked",
                                   on_rid_Button_clicked'Access,
                                   Self);

         Label_return_Callbacks.Connect (Self.colon_Label,
                                         "button-release-event",
                                         on_colon_Label_clicked'Access,
                                         Self);

         Label_return_Callbacks.Connect (Self.initializer_Label,
                                         "button-release-event",
                                         on_initialiser_Label_clicked'Access,
                                         Self);

         Self.freshen;

         return Self;
      end new_Editor;
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
      if Self.Target.is_Aliased
      then   Self.aliased_Label.show;
      else   Self.aliased_Label.hide;
      end if;

      if Self.Target.Default = ""
      then   Self.default_Entry.hide;
      else   Self.default_Entry.show;
      end if;

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


end aIDE.Editor.of_record_component;
