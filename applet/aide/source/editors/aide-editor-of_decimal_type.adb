with
     glib.Error,

     gtk.Builder,
     gtk.Handlers;

with Ada.Text_IO; use Ada.Text_IO;


package body aIDE.Editor.of_decimal_type
is
   use Gtk.Builder,

       Glib,
       glib.Error;


   function on_name_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                 Target    : in     AdaM.a_Type.decimal_fixed_point_type.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.Name_is (the_Text);
      return False;
   end on_name_Entry_leave;


   function on_delta_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                  Target    : in     AdaM.a_Type.decimal_fixed_point_type.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.Delta_is (the_Text);
      return False;
   end on_delta_Entry_leave;


   function on_digits_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                   Target    : in     AdaM.a_Type.decimal_fixed_point_type.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.Digits_is (the_Text);
      return False;
   end on_digits_Entry_leave;


   function on_first_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                  Target    : in     AdaM.a_Type.decimal_fixed_point_type.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.First_is (the_Text);
      return False;
   end on_first_Entry_leave;


   function on_last_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                 Target    : in     AdaM.a_Type.decimal_fixed_point_type.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.Last_is (the_Text);
      return False;
   end on_last_Entry_leave;



   procedure on_rid_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                    the_Editor : in     aIDE.Editor.of_decimal_type.view)
   is
      pragma Unreferenced (the_Editor);
   begin
      the_Button.get_Parent.destroy;
   end on_rid_Button_clicked;



   package Entry_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Entry_Record,
                                                                            Boolean,
                                                                            AdaM.a_Type.decimal_fixed_point_type.view);

   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Editor.of_decimal_type.view);



   function on_is_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                 Self      : in     aIDE.Editor.of_decimal_type.view) return Boolean
   is
      pragma Unreferenced (the_Label);
   begin
--        Self.Target.add_Literal ("literal");
      Self.freshen;

      return False;
   end on_is_Label_clicked;


   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_decimal_type.view);

   package body Forge
   is
      function to_Editor (the_Target : in AdaM.a_Type.decimal_fixed_point_type.view) return View
      is
         use AdaM,
             Glib;

         Self        : constant Editor.of_decimal_type.view := new Editor.of_decimal_type.item;

         the_Builder :          Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;
         pragma Unreferenced (Result);

      begin
         Self.Target := the_Target;

         Gtk_New (the_Builder);
         Result := the_Builder.Add_From_File ("glade/editor/decimal_type_editor.glade", Error'Access);

         if Error /= null then
            raise Program_Error with "Error: adam.Editor.of_enumeration_type ~ " & Get_Message (Error);
         end if;

         Self.top_Box      := gtk_Box    (the_Builder.get_Object ("top_Box"));
         Self.name_Entry   := Gtk_Entry  (the_Builder.get_Object ("name_Entry"));
         Self.delta_Entry  := Gtk_Entry  (the_Builder.get_Object ("delta_Entry"));
         Self.digits_Entry := Gtk_Entry  (the_Builder.get_Object ("digits_Entry"));
         Self.first_Entry  := Gtk_Entry  (the_Builder.get_Object ("first_Entry"));
         Self.last_Entry   := Gtk_Entry  (the_Builder.get_Object ("last_Entry"));
         Self.rid_Button   := gtk_Button (the_Builder.get_Object ("rid_Button"));

         Self.name_Entry.Set_Text (+Self.Target.Name);

         Entry_return_Callbacks.connect (Self.name_Entry,
                                         "focus-out-event",
                                         on_name_Entry_leave'Access,
                                         the_Target);

         Button_Callbacks.Connect (Self.rid_Button,
                                   "clicked",
                                   on_rid_Button_clicked'Access,
                                   Self);

         Entry_return_Callbacks.connect (Self.delta_Entry,
                                         "focus-out-event",
                                         on_delta_Entry_leave'Access,
                                         the_Target);

         Entry_return_Callbacks.connect (Self.digits_Entry,
                                         "focus-out-event",
                                         on_digits_Entry_leave'Access,
                                         the_Target);

         Entry_return_Callbacks.connect (Self.first_Entry,
                                         "focus-out-event",
                                         on_first_Entry_leave'Access,
                                         the_Target);

         Entry_return_Callbacks.connect (Self.last_Entry,
                                         "focus-out-event",
                                         on_last_Entry_leave'Access,
                                         the_Target);


--           Label_return_Callbacks.Connect (Self.is_Label,
--                                           "button-release-event",
--                                           on_is_Label_clicked'Access,
--                                           Self);
         Self.freshen;

         return Self;
      end to_Editor;
   end Forge;



   overriding
   procedure freshen (Self : in out Item)
   is
      use gtk.Widget;
   begin
      Self. delta_Entry.set_Text (Self.Target.my_Delta);
      Self.digits_Entry.set_Text (Self.Target.my_Digits);

      Self.first_Entry.set_Text (Self.Target.First);
      Self. last_Entry.set_Text (Self.Target.Last);
   end freshen;



   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.top_Box);
   end top_Widget;


end aIDE.Editor.of_decimal_type;
