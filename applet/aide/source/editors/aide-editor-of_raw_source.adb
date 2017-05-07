with
     Glib,
     glib.Error,

     gtk.Builder,
     gtk.Handlers,
     gtk.Text_Buffer,
     gtk.Text_Iter,
     gtk.Enums,

     ada.Characters.Latin_1;


package body aIDE.Editor.of_raw_source
is
   use gtk.Builder,
       gtk.Text_Buffer,
       gtk.Text_Iter,

       Glib,
       glib.Error;


   function on_comment_text_View_leave (the_Entry     : access Gtk_Text_View_Record'Class;
                                        the_Operation : in     adam.raw_Source.view) return Boolean
   is
      use Gtk.Text_Iter;
      Start   : Gtk_Text_Iter;
      the_End : Gtk_Text_Iter;
      Continue : Boolean;

      the_Lines : adam.text_Lines;
   begin
      the_Entry.Get_Buffer.get_start_Iter (Start);
      the_End := Start;
      Forward_Line (the_End, Continue);

      if Start = the_End
      then
         return False;
      end if;


      loop
         declare
            use Adam;
            the_Text : constant String := the_Entry.Get_Buffer.Get_Text (Start, the_End);
         begin
            if the_Text (the_Text'Last) = ada.Characters.Latin_1.LF
            then
               the_Lines.append (+the_Text (the_Text'First .. the_Text'Last - 1));   -- Drop Line Feed.
            else
               the_Lines.append (+the_Text);
            end if;
         end;

         exit when not Continue;

         Start   := the_End;
         the_End := Start;

         Forward_Line (the_End, Continue);
      end loop;

      the_Operation.Lines_are (the_Lines);

      return False;
   end on_comment_text_View_leave;



   procedure on_rid_Button_clicked (the_Button            : access Gtk_Button_Record'Class;
                                    the_raw_source_Editor : in     aIDE.Editor.of_raw_source.view)
   is

   begin
      the_Button.get_Parent.get_Parent.get_Parent.destroy;
   end on_rid_Button_clicked;



   package text_View_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Text_View_Record,
                                                                                Boolean,
                                                                                adam.raw_Source.view);

   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Editor.of_raw_Source.view);



   package body Forge
   is
      function to_comment_Editor (the_Comment : in adam.raw_Source.view) return View
      is
         Self        : constant Editor.of_raw_Source.view := new Editor.of_raw_Source.item;

         the_Builder :          Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;

      begin
         Self.Comment := the_Comment;

         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/raw_source_editor.glade", Error'Access);

         if Error /= null then
            raise Program_Error with "Error: adam.Editor.context_line ~ " & Get_Message (Error);
         end if;

         Self.Top                  := gtk_Frame        (the_Builder.get_Object ("top_Frame"));

         Self.comment_text_View    := gtk_Text_View    (the_Builder.get_Object ("source_text_View"));
         Self.comment_text_View.Override_Background_Color (State => Gtk.Enums.Gtk_State_Flag_Normal,
                                                           Color => (0.85, 0.92, 0.98,
                                                                     1.0));

         Self.parameters_Alignment := gtk_Alignment    (the_Builder.get_Object ("top_Alignment"));
         Self.rid_Button           := gtk_Button       (the_Builder.get_Object ("rid_Button"));

         Text_View_return_Callbacks.Connect (Self.comment_text_View,
                                         "focus-out-event",
                                         on_comment_text_View_leave'Access,
                                         the_Comment);

         Button_Callbacks.Connect (Self.rid_Button,
                                   "clicked",
                                   on_rid_Button_clicked'Access,
                                   Self);
         declare
            use Adam;

            Buffer : constant Gtk_Text_Buffer := Self.comment_text_View.Get_Buffer;
            Iter   :          Gtk_Text_Iter;
         begin
            Buffer.Get_Start_Iter (Iter);

            for i in 1 .. Natural (the_Comment.Lines.Length)
            loop
               if i /= Natural (the_Comment.Lines.Length)
               then
                  Buffer.Insert (Iter, +Self.Comment.Lines.Element (i) & Ada.Characters.Latin_1.LF);
               else
                  Buffer.Insert (Iter, +Self.Comment.Lines.Element (i));
               end if;
            end loop;
         end;

         return Self;
      end to_comment_Editor;
   end Forge;



   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.Top);
   end top_Widget;


end aIDE.Editor.of_raw_source;
