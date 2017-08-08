with
     AdaM.Declaration.of_exception,
     AdaM.Assist,

     aIDE.Editor.of_block,
     aIDE.GUI,

     Glib,
     glib.Error,

     gtk.Builder,
     gtk.Handlers,

     ada.unchecked_Deallocation;
with Ada.Text_IO; use Ada.Text_IO;


package body aIDE.Editor.of_exception_handler
is
   use Glib,
       glib.Error,
       gtk.Builder;


   type editor_slot_Pair is
      record
         Editor : aIDE.editor.of_exception_handler.view;
         Slot   : Positive;
      end record;


   package Button_user_Handler is new Gtk.Handlers.user_Callback (Gtk_Button_Record,
                                                                  editor_slot_Pair);


   procedure on_rid_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                    Pair       : in     editor_slot_Pair)
   is
      the_Editor : editor.of_exception_handler.view := Pair.Editor;
   begin
      the_Editor.exception_Handler.destruct;
      free (the_Editor);
   end on_rid_Button_clicked;



   procedure On_Clicked (the_Button : access Gtk_Button_Record'Class;
                         Pair       : in     editor_slot_Pair)
   is
      --        use gtk.Button;
   begin
      aIDE.GUI.show_exceptions_Palette (Invoked_by => gtk_Button (the_Button),
                                        Target     => Pair.Editor.exception_Handler,
                                        Slot       => Pair.Slot);
   end On_Clicked;


   package Label_user_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                                 Boolean,
                                                                                 Editor.of_exception_handler.view);


   function on_when_Label_clicked (the_Label : access Gtk.Label.Gtk_Label_Record'Class;
                                   Self      : in     Editor.of_exception_handler.view) return Boolean
   is
      function next_free_Slot return Natural
      is
      begin
         for i in 1 .. Self.exception_Handler.exception_Count
         loop
            if Self.exception_Handler.is_Free (i) then
               return i;
            end if;
         end loop;

         return 0;
      end next_free_Slot;

      Slot : constant Natural := next_free_Slot;

   begin
      put_Line ("SLOT: " & Integer'Image (Slot));

      if Slot = 0
      then
--           Self.exception_Handler.my_add_Exception (null);
         Self.exception_Handler.add_Exception (aIDE.the_entity_Environ.find ("Constraint_Error"));
--           Self.exception_Handler.add_Exception ("constraint_Error");

         Self.add_new_exception_Button (Self.exception_Handler.exception_Count);
      else
--           Self.exception_Handler.exception_Name_is (Slot, null);
         Self.exception_Handler.my_Exception_is (Slot, aIDE.the_entity_Environ.find ("Constraint_Error")); --"constraint_Error");
         Self.exception_Button (Slot).Show_All;
      end if;

      return False;
   end on_when_Label_clicked;




   function exception_Button (Self : in Item;   Slot : in Positive) return gtk_Button
   is
      the_Child : constant Gtk.Widget.gtk_Widget := Self.exception_names_Box.Get_Child (Gint (Slot) - 1);
   begin
      return gtk_Button (the_Child);
   end exception_Button;



   procedure add_new_exception_Button (Self : access Item;   Slot : in Positive)
   is
      use Gtk.Widget.Widget_List;
      use type AdaM.Declaration.of_exception.view;

      new_Button    : gtk_Button;
      the_Exception : AdaM.Declaration.of_exception.view := Self.exception_Handler.my_Exception (slot);
   begin
      gtk_New (new_Button);

      if the_Exception = null
      then
         new_Button.Set_Tooltip_Text ("Not yet set.");
      else
         new_Button.Set_Tooltip_Text (the_Exception.full_Name);
         new_Button.Set_Label        (AdaM.Assist.strip_standard_Prefix (the_Exception.Name));
      end if;

      Self.exception_names_Box.pack_Start (new_Button, expand => True, fill => True);

      if not Self.exception_Handler.is_Free (Slot)
      then
         new_Button.Show;
      else
         new_Button.Hide;
      end if;

      Button_user_Handler.Connect (new_Button,
                                   "clicked",
                                   On_Clicked'Access,
                                   (View (Self),
                                    Slot));
   end add_new_exception_Button;




   --  Forge
   --
   function new_Editor (the_Handler : in AdaM.exception_Handler.view) return View
   is
      Self        : constant Editor.of_exception_handler.view := new Editor.of_exception_handler.item;

      the_Builder :          Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;

   begin
      Self.exception_Handler := the_Handler;

      Gtk_New (the_Builder);

      Result := the_Builder.Add_From_File ("glade/editor/exception_handler_editor.glade", Error'Access);

      if Error /= null then
         Error_Free (Error);
      end if;

      Self.top_Frame           := gtk_Frame     (the_Builder.get_Object ("top_Frame"));
      Self.top_Box             := gtk_Box       (the_Builder.get_Object ("top_Box"));
      Self.handler_Alignment   := gtk_Alignment (the_Builder.get_Object ("handler_Alignment"));

      Self.when_Label          := gtk_Label     (the_Builder.get_Object ("when_Label"));
      Self.exception_names_Box := gtk_Box       (the_Builder.get_Object ("exception_names_Box"));

      Self.rid_Button          := gtk_Button    (the_Builder.get_Object ("rid_Button"));


      Self.block_Editor := aIDE.Editor.of_block.Forge.to_block_Editor (Self.exception_Handler.Handler);
      Self.block_Editor.top_Widget.reparent (Self.handler_Alignment);

      for i in 1 .. Self.exception_Handler.exception_Count
      loop
         Self.add_new_exception_Button (i);
      end loop;

      Label_user_return_Callbacks.Connect (Self.when_Label,
                                           "button-release-event",
                                           on_when_Label_clicked'Access,
                                           Self);

      Button_user_Handler.Connect (Self.rid_Button,
                                   "clicked",
                                   on_rid_Button_clicked'Access,
                                   (Self, 1));
      return Self;
   end new_Editor;



   procedure free (the_Handler : in out View)
   is
      procedure deallocate is new ada.Unchecked_Deallocation (Item'Class, View);
   begin
      the_Handler.top_Frame.destroy;
      deallocate (the_Handler);
   end free;



   overriding function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.top_Frame);
   end top_Widget;


end aIDE.Editor.of_exception_handler;
