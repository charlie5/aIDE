with
     aIDE.GUI,

     AdaM.exception_Handler,

     glib,
     glib.Error,

     gtk.Builder,

     gdk.Event;


package body aIDE.Editor.of_block
is

   use gtk.Builder,
       gtk.Widget,
       glib,
       glib.Error;




   function exception_Button_Press
      (Self  : access Gtk_Widget_Record'Class;
       Event : Gdk.Event.Gdk_Event_Button) return Boolean
   is
      Expander : constant my_Expander := my_Expander (Self);
   begin
      case Event.Button
      is
         when 1 =>
            return False;

         when 2 =>
            declare
               new_Handler : constant AdaM.exception_Handler.view
                 := AdaM.exception_Handler.new_Handler ("constraint_Error",
                                                        Expander.Editor.Block);
            begin
               Expander.Editor.Block.add (new_Handler);

               Expander.Editor.exception_Handler := aIDE.Editor.of_exception_handler.new_Editor (new_Handler);
               Expander.Editor.exception_Handler.top_Widget.reparent (Expander.Editor.exception_Box);
            end;

         when others =>
            null;
      end case;

      return True;
   end exception_Button_Press;



   function Button_Press
      (Self  : access Gtk_Widget_Record'Class;
       Event : Gdk.Event.Gdk_Event_Button) return Boolean
   is
      Expander : constant my_Expander := my_Expander (Self);
   begin
      case Event.Button
      is
         when 1 =>
            return False;

         when 2 =>
            aIDE.GUI.show_source_entities_Palette (Invoked_by => Expander.Editor.all'Access,
                                                   Target     => Expander.Target);
         when others =>
            null;
      end case;

      return True;
   end Button_Press;



   package body Forge
   is
      function to_block_Editor (the_Block : in AdaM.Block.view) return View
      is
         Self : constant Editor.of_block.view := new Editor.of_block.item;

         the_Builder : Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;

         use gdk.Event;
      begin
         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/block_editor.glade", Error'Access);

         if Error /= null
         then
            Error_Free (Error);
         end if;

         Self.block_editor_Frame := gtk_Frame (the_Builder.get_Object ("block_editor_Frame"));
         Self.top_Box := gtk_Box (the_Builder.get_Object ("top_Box"));


         -- declare region
         --
         Self.declare_Expander        := new my_Expander_Record;
         Self.declare_Expander.Target := the_Block.my_Declarations;
         Self.declare_Expander.Editor := Self;
         gtk.Expander.Initialize (Self.declare_Expander, "declare");
         Self.declare_Expander.On_Button_Press_Event (Button_Press'Access);

         Self.top_Box.Pack_Start (Self.declare_Expander);

         Self.declare_Label := Gtk_Label (the_Builder.get_Object ("declare_Label"));

         Gtk_New_Vbox (Self.declare_Box);
         Self.declare_Expander.Add (Self.declare_Box);


         -- begin region
         --
         Self.begin_Expander        := new my_Expander_Record;
         Self.begin_Expander.Target := the_Block.my_Statements;
         Self.begin_Expander.Editor := Self;
         gtk.Expander.Initialize (Self.begin_Expander, "begin");
         Self.begin_Expander.On_Button_Press_Event (Button_Press'Access);

         Self.top_Box.Pack_Start (Self.begin_Expander);

         Gtk_New_Vbox (Self.begin_Box);
         Self.begin_Expander.Add (Self.begin_Box);


         -- exception region
         --
         Self.exception_Expander        := new my_Expander_Record;
         Self.exception_Expander.Target := the_Block.my_Handlers;
         Self.exception_Expander.Editor := Self;
         gtk.Expander.Initialize (Self.exception_Expander, "exception");
         Self.exception_Expander.On_Button_Press_Event (exception_Button_Press'Access);

         Self.top_Box.Pack_Start (Self.exception_Expander);

         Gtk_New_Vbox (Self.exception_Box);
         Self.exception_Expander.Add (Self.exception_Box);

         Self.Block := the_Block;

         Self.top_Widget.Show_All;
         Self.freshen;

         return Self;
      end to_block_Editor;
   end Forge;



   overriding
   procedure freshen (Self : in out Item)
   is
      use AdaM;
   begin
      -- 'declare' Region
      --

      -- Destroy all prior 'declare' entity widgets.
      --
      loop
         declare
            the_Child : constant gtk_Widget := Self.declare_Box.get_Child (0);
         begin
            exit when the_Child = null;
            the_Child.destroy;
         end;
      end loop;


      -- Create all 'declare' entity widgets.
      --
      declare
         the_Entities : constant AdaM.Source.Entities_View := Self.Block.my_Declarations;
      begin
         for i in 1 .. Integer (the_Entities.Length)
         loop
            declare
               the_Entity : AdaM.Source.Entity_view renames the_Entities.Element (i);
               the_Editor : constant aIDE.Editor.view        :=      aIDE.Editor.to_Editor (the_Entity);
            begin
               the_Editor.top_Widget.reparent (Self.declare_Box);
            end;
         end loop;
      end;


      -- 'begin' Region
      --

      -- Destroy all prior 'begin' entity widgets.
      --
      loop
         declare
            the_Child : constant gtk_Widget := Self.begin_Box.get_Child (0);
         begin
            exit when the_Child = null;
            the_Child.destroy;
         end;
      end loop;


      -- Create all 'begin' entity widgets.
      --
      declare
         the_Entities : constant access AdaM.Source.Entities := Self.Block.my_Statements;
      begin
         for i in 1 .. Integer (the_Entities.Length)
         loop
            declare
               the_Entity :          AdaM.Source.Entity_view renames the_Entities.Element (i);
               the_Editor : constant aIDE.Editor.view        :=      aIDE.Editor.to_Editor (the_Entity);
            begin
               the_Editor.top_Widget.reparent (Self.begin_Box);
            end;
         end loop;
      end;


      -- Exceptions
      --
      loop
         declare
            use gtk.Widget;
            the_Child : constant gtk_Widget := Self.exception_Box.Get_Child (0);
         begin
            exit when the_Child = null;
            the_Child.destroy;
         end;
      end loop;

      for i in 1 .. Integer (Self.Block.my_Handlers.Length)
      loop
         declare
            the_Entity    : constant AdaM.Source.Entity_View     := Self.Block.my_Handlers.Element (i);
            the_Exception : constant AdaM.exception_Handler.view := AdaM.exception_Handler.view  (the_Entity);
         begin
            Self.exception_Handler := aIDE.Editor.of_exception_handler.new_Editor (the_Exception);
            Self.exception_Handler.top_Widget.reparent (Self.exception_Box);
         end;
      end loop;

   end freshen;



   procedure Target_is (Self : in out Item;   Now : AdaM.Block.view)
   is
      Unused : Boolean;
   begin
      Self.Block := Now;
      Self.freshen;
   end Target_is;



   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.block_editor_Frame);
   end top_Widget;


end aIDE.Editor.of_block;
