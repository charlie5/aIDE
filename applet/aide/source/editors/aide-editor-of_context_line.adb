with
     aIDE.GUI,
     Glib,
     Glib.Error,

     Gtk.Builder,
     Gtk.Handlers;


package body aIDE.Editor.of_context_line
is
   use gtk.Builder,
       Glib,
       glib.Error;


   procedure on_name_Button_clicked (the_Button              : access Gtk_Button_Record'Class;
                                     the_context_line_Editor : in     aIDE.Editor.of_context_Line.view)
   is

   begin
      aIDE.GUI.show_packages_Palette (Invoked_by => gtk_Button (the_Button),
                                      Target     => the_context_line_Editor.context_Line);

      null;
   end on_name_Button_clicked;




   function on_used_Button_leave (the_Button       : access Gtk_Check_Button_Record'Class;
                                  the_Context_Line : in     AdaM.context_Line.view) return Boolean
   is
   begin
      the_Context_Line.is_Used (the_Button.get_Active);

      return False;
   end on_used_Button_leave;



   procedure on_rid_Button_clicked (the_Button              : access Gtk_Button_Record'Class;
                                    the_context_line_Editor : in     aIDE.Editor.of_context_Line.view)
   is

   begin
      the_context_line_Editor.Context.rid (the_context_line_Editor.context_Line);
      the_Button.get_Parent.destroy;
   end on_rid_Button_clicked;



   package check_Button_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Check_Button_Record,
                                                                                   Boolean,
                                                                                   AdaM.Context_Line.view);

   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Editor.of_context_Line.view);



   package body Forge
   is
      function to_context_line_Editor (the_Context      : in AdaM.Context     .view;
                                       the_Context_Line : in AdaM.context_Line.view) return View
      is
         Self        : constant Editor.of_context_Line.view := new Editor.of_context_Line.item;

         the_Builder : Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;
         pragma Unreferenced (Result);

      begin
         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/context_line_editor.glade", Error'Access);

         if Error /= null then
            raise Program_Error with "Error: adam.Editor.context_line ~ " & Get_Message (Error);
         end if;

         Self.Top               := gtk_Box          (the_Builder.get_Object ("top_Box"));
         Self.name_Button       := gtk_Button       (the_Builder.get_Object ("name_Button"));
         Self.used_Button       := gtk_Check_Button (the_Builder.get_Object ("used_Button"));
         Self.rid_Button        := gtk_Button       (the_Builder.get_Object ("rid_Button"));

         Button_Callbacks.Connect (Self.name_Button,
                                   "clicked",
                                   on_name_Button_clicked'Access,
                                   Self); -- the_Context_Line);

         check_Button_return_Callbacks.Connect (Self.used_Button,
                                                "focus-out-event",
                                                on_used_Button_leave'Access,
                                                the_Context_Line);

         Button_Callbacks.Connect (Self.rid_Button,
                                   "clicked",
                                   on_rid_Button_clicked'Access,
                                   Self);

         Self.name_Button.set_Label  (the_Context_Line.Name);
         Self.used_Button.Set_Active (the_Context_Line.is_Used);

         Self.Context      := the_Context;
         Self.context_Line := the_Context_Line;

         return Self;
      end to_context_line_Editor;
   end Forge;



   overriding function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.Top);
   end top_Widget;



   function name_Button  (Self : in Item) return gtk.Button.gtk_Button
   is
   begin
      return Self.name_Button;
   end name_Button;



   function context_Line (Self : in Item) return AdaM.context_Line.view
   is
   begin
      return Self.context_Line;
   end context_Line;


end aIDE.Editor.of_context_line;
