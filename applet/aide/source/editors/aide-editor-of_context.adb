with
     Glib,
     glib.Error,

     gtk.Builder,
     gtk.Handlers,

     AdaM.context_Line,
     aIDE.Editor.of_context_line;


package body aIDE.Editor.of_context
is
   use gtk.Builder,
       Glib,
       Glib.Error;


   function on_context_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                      Self      : in     aIDE.Editor.of_context.view) return Boolean
   is
      use AdaM;

      the_Line        : constant AdaM.context_Line          .view := AdaM.context_Line.new_context_Line ("anon");
      the_Line_Editor : constant aIDE.Editor.of_context_line.view := Editor.of_context_line.Forge.to_context_line_Editor (Self.Context,
                                                                                                                               the_Line);
   begin
      the_Line_Editor.top_Widget.reparent (Self.context_lines_Box);

      Self.Context.add (the_Line);

      return False;
   end on_context_Label_clicked;



   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_context.view);

   package body Forge
   is
      function to_context_Editor (the_Context : in AdaM.Context.view) return View
      is
         Self        : constant Editor.of_context.view := new Editor.of_context.item;

         the_Builder :          Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;

      begin
         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/context_editor.glade", Error'Access);

         if Error /= null then
            Error_Free (Error);
         end if;

         Self.Top               := gtk_Frame     (the_Builder.get_Object ("top_Frame"));
         Self.context_Label     := gtk_Label     (the_Builder.get_Object ("context_Label"));
         Self.context_lines_Box := gtk_Box       (the_Builder.get_Object ("context_lines_Box"));

         Label_return_Callbacks.Connect (Self.context_Label,
                                         "button-release-event",
                                         on_context_Label_clicked'Access,
                                         Self);
         Self.Context := the_Context;
         Self.freshen;

         return Self;
      end to_context_Editor;
   end Forge;



   procedure Context_is (Self : in out Item;   Now : in AdaM.Context.view)
   is
   begin
      Self.Context := Now;
      Self.freshen;
   end Context_is;



   overriding function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.Top);
   end top_Widget;



   overriding
   procedure freshen (Self : in out Item)
   is
      the_Lines       : constant AdaM.context_Line.Vector := Self.Context.Lines;
   begin
      loop
         declare
            the_Child : constant gtk_Widget := Self.context_lines_Box.Get_Child (0);
         begin
            exit when the_Child = null;
            the_Child.destroy;
         end;
      end loop;

      for i in 1 .. Integer (the_Lines.Length)
      loop
         declare
            the_Line        :          AdaM.context_line          .view renames the_Lines.Element (i);
            the_Line_Editor : constant aIDE.Editor.of_context_line.view :=      Editor.of_context_line.Forge.to_context_line_Editor (Self.Context,
                                                                                                                                          the_Line);
         begin
            the_Line_Editor.top_Widget.reparent (Self.context_lines_Box);
         end;
      end loop;
   end freshen;


end aIDE.Editor.of_context;
