with
     Glib,
     glib.Error,

     gtk.Builder,
     gtk.Handlers;


package body aIDE.Editor.of_subprogram
is
   use gtk.Builder,

       Glib,
       glib.Error;


   function on_name_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                 Self      : in     aIDE.Editor.of_subprogram.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Self.Subprogram.Name_is (the_Text);
      return False;
   end on_name_Entry_leave;


   package Entry_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Entry_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_subprogram.view);


   function on_procedure_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                        Self      : in     aIDE.Editor.of_subprogram.view) return Boolean
   is
   begin
      return False;
   end on_procedure_Label_clicked;



   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_subprogram.view);


   package body Forge
   is
      function to_subprogram_Editor (the_Subprogram : in adam.Subprogram.view) return View
      is
         Self : constant Editor.of_subprogram.view := new Editor.of_subprogram.item;

         the_Builder : Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;

      begin
         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/subprogram_editor.glade", Error'Access);

         if Error /= null then
            Error_Free (Error);
         end if;

         Self.top_Box           := gtk_Box       (the_Builder.get_Object ("top_Box"));
         Self.block_Alignment   := gtk_Alignment (the_Builder.get_Object ("block_Alignment"));
         Self.context_Alignment := gtk_Alignment (the_Builder.get_Object ("context_Alignment"));
         Self.procedure_Label   := gtk_Label     (the_Builder.get_Object ("procedure_Label"));
         Self.name_Entry        := gtk_Entry     (the_Builder.get_Object ("name_Entry"));

         Entry_return_Callbacks.Connect (Self.name_Entry,
                                         "focus-out-event",
                                         on_name_Entry_leave'Access,
                                         Self);

         Label_return_Callbacks.Connect (Self.procedure_Label,
                                         "button-release-event",
                                         on_procedure_Label_clicked'Access,
                                         Self);


         Self.Subprogram   := the_Subprogram;

         Self.context_Editor := aIDE.Editor.of_context.Forge.to_context_Editor (Self.Subprogram.Context);
         Self.context_Editor.top_Widget.Reparent (new_Parent => Self.context_Alignment);

         Self.block_Editor := aIDE.Editor.of_block.Forge.to_block_Editor (Self.Subprogram.Block);
         Self.block_Editor.top_Widget.Reparent (new_Parent => Self.block_Alignment);

         Self.freshen;

         return Self;
      end to_subprogram_Editor;
   end Forge;


   overriding
   procedure freshen (Self : in out Item)
   is
   begin
      Self.name_Entry.Set_Text (Self.Subprogram.Name);

      Self.context_Editor.Context_is (Self.Subprogram.Context);
      Self.  block_Editor.Target_is (Self.Subprogram.Block);
   end freshen;



   function  Target (Self : in     Item)     return adam.Subprogram.view
   is
   begin
      return Self.Subprogram;
   end Target;


   procedure Target_is (Self : in out Item;   Now : in adam.Subprogram.view)
   is
   begin
      Self.Subprogram := Now;
      Self.freshen;
   end Target_is;


   overriding function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.top_Box);
   end top_Widget;


end aIDE.Editor.of_subprogram;
