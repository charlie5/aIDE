with
     aIDE.Palette.of_pragmas,
     aIDE.GUI,

     Glib,
     glib.Error,

     gtk.Builder,
     gtk.Handlers,

     Ada.Containers;
with Ada.Text_IO; use Ada.Text_IO;


package body aIDE.Editor.of_pragma
is
   use gtk.Builder,

       Glib,
       glib.Error;


   function on_name_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                 Self      : in     aIDE.Editor.of_pragma.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Self.Target.Name_is (the_Text);
      return False;
   end on_name_Entry_leave;


   package Entry_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Entry_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_pragma.view);


   function on_procedure_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                        Self      : in     aIDE.Editor.of_pragma.view) return Boolean
   is
   begin
      return False;
   end on_procedure_Label_clicked;



   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_pragma.view);


   procedure on_choose_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                      Self       : in     aIDE.Editor.of_pragma.view)
   is
   begin
      put_Line ("YAY YAY");
      aIDE.GUI.show_pragma_Palette (Invoked_by => Self.all'Access,
                                    Target     => Self.Target);
   end on_choose_Button_clicked;


   package Button_return_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
--                                                                               Boolean,
                                                                      aIDE.Editor.of_pragma.view);





   package body Forge
   is
      function new_Editor (the_Pragma : in AdaM.a_Pragma.view) return View
      is
         Self : constant Editor.of_pragma.view := new Editor.of_pragma.item;

         the_Builder : Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;
         pragma Unreferenced (Result);

      begin
         Gtk_New (the_Builder);

         Result := the_Builder.add_from_File ("glade/editor/pragma_editor.glade", Error'Access);

         if Error /= null then
            Error_free (Error);
         end if;

         Self.top_Frame         := gtk_Frame     (the_Builder.get_Object ("top_Frame"));
         Self.top_Box           := gtk_Box       (the_Builder.get_Object ("top_Box"));
         Self.choose_Button     := gtk_Button    (the_Builder.get_Object ("choose_pragma_Button"));
         Self.arguments_Box     := gtk_Box       (the_Builder.get_Object ("arguments_Box"));
--           Self.block_Alignment   := gtk_Alignment (the_Builder.get_Object ("block_Alignment"));
--           Self.context_Alignment := gtk_Alignment (the_Builder.get_Object ("context_Alignment"));

         Self.open_parenthesis_Label  := gtk_Label     (the_Builder.get_Object ("open_parenthesis_Label"));
         Self.close_parenthesis_Label := gtk_Label     (the_Builder.get_Object ("close_parenthesis_Label"));

--           Self.name_Entry        := gtk_Entry     (the_Builder.get_Object ("name_Entry"));

--           Entry_return_Callbacks.Connect (Self.name_Entry,
--                                           "focus-out-event",
--                                           on_name_Entry_leave'Access,
--                                           Self);

--           Label_return_Callbacks.Connect (Self.procedure_Label,
--                                           "button-release-event",
--                                           on_procedure_Label_clicked'Access,
--                                           Self);


         Button_return_Callbacks.Connect (Self.choose_Button,
                                         "clicked",
                                         on_choose_Button_clicked'Access,
                                         Self);



         Self.Target   := the_Pragma;

--           Self.context_Editor := aIDE.Editor.of_context.Forge.to_context_Editor (Self.Subprogram.Context);
--           Self.context_Editor.top_Widget.Reparent (new_Parent => Self.context_Alignment);
--
--           Self.block_Editor := aIDE.Editor.of_block.Forge.to_block_Editor (Self.Subprogram.Block);
--           Self.block_Editor.top_Widget.Reparent (new_Parent => Self.block_Alignment);

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
      use AdaM;
      use type Ada.Containers.Count_Type;

      Args : constant text_Lines := Self.Target.Arguments;
   begin
      Self.arguments_Box.forEach (destroy_Callback'Access);
      Self.choose_Button.set_Label (String (Self.Target.Name));

      if Args.Length = 0
      then
         Self. open_parenthesis_Label.hide;
         Self.close_parenthesis_Label.hide;
      else
         Self. open_parenthesis_Label.show;
         Self.close_parenthesis_Label.show;

         for Each of Args
         loop
            declare
               new_Entry : constant gtk_Entry := Gtk_Entry_New;
               Arg       : constant String    := +Each;
            begin
--                 put_Line ("ZZZZZZZZZZZZZZZZZ " & (+Each));
               new_Entry.set_Width_chars (Arg'Length);
               new_Entry.set_Text (Arg);
               Self.arguments_Box.pack_Start (new_Entry);
--                                                Expand  => True,
--                                                Fill    => True,
--                                                Padding => 0);
            end;
         end loop;

         Self.arguments_Box.show_All;
      end if;

      --        Self.top_Frame.Show_All;
--        Self.top_Widget.show_All;

--        Self.name_Entry.Set_Text (+Self.Target.Name);

--        Self.context_Editor.Context_is (Self.Subprogram.Context);
--        Self.  block_Editor.Target_is (Self.Subprogram.Block);
   end freshen;



   function  Target (Self : in     Item)     return AdaM.a_Pragma.view
   is
   begin
      return Self.Target;
   end Target;


   procedure Target_is (Self : in out Item;   Now : in AdaM.a_Pragma.view)
   is
   begin
      Self.Target := Now;
      Self.freshen;
   end Target_is;


   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
--        return gtk.Widget.Gtk_Widget (Self.top_Frame);
      return gtk.Widget.Gtk_Widget (Self.top_Box);
   end top_Widget;


end aIDE.Editor.of_pragma;
