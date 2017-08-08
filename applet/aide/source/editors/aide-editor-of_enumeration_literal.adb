with
     AdaM.a_Type.enumeration_type,

     Glib,
     Glib.Error,

     Gtk.Builder,
     Gtk.Handlers;


package body aIDE.Editor.of_enumeration_literal
is
   use Gtk.Builder,

       Glib,
       glib.Error;


   function on_name_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                 Target    : in     AdaM.a_Type.enumeration_literal.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Target.Name_is (the_Text);
      return False;
   end on_name_Entry_leave;



   procedure on_rid_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                    the_Editor : in     aIDE.Editor.of_enumeration_literal.view)
   is

   begin
      the_Editor.Targets_Parent.rid_Literal (the_Editor.Target.Name);
      the_Button.get_Parent.destroy;
   end on_rid_Button_clicked;



   package Entry_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Entry_Record,
                                                                            Boolean,
                                                                            AdaM.a_Type.enumeration_literal.view);

   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Editor.of_enumeration_literal.view);


   package body Forge
   is
      function to_Editor (the_Target     : in AdaM.a_Type.enumeration_literal.view;
                          targets_Parent : in enumeration_type_view) return View
      is
         Self        : constant Editor.of_enumeration_literal.view := new Editor.of_enumeration_literal.item;

         the_Builder :          Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;
         pragma Unreferenced (Result);

      begin
         Self.Target         := the_Target;
         Self.Targets_Parent := targets_Parent;

         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/enumeration_literal_editor.glade", Error'Access);

         if Error /= null then
            raise Program_Error with "Error: adam.Editor.of_enumeration_literal ~ " & Get_Message (Error);
         end if;

         Self.top_Box      := gtk_Box    (the_Builder.get_Object ("top_Box"));
         Self.name_Entry   := Gtk_Entry  (the_Builder.get_Object ("name_Entry"));
         Self.rid_Button   := gtk_Button (the_Builder.get_Object ("rid_Button"));

         Self.name_Entry.Set_Text (Self.Target.Name);

         Entry_return_Callbacks.connect (Self.name_Entry,
                                         "focus-out-event",
                                         on_name_Entry_leave'Access,
                                         the_Target);

         Button_Callbacks.Connect (Self.rid_Button,
                                   "clicked",
                                   on_rid_Button_clicked'Access,
                                   Self);
         return Self;
      end to_Editor;
   end Forge;



   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.top_Box);
   end top_Widget;


end aIDE.Editor.of_enumeration_literal;
