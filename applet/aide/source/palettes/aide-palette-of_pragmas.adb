with
     AdaM.Comment,
     AdaM.raw_Source,
     AdaM.a_Type.enumeration_type,

     Glib,
     Glib.Error,
     Glib.Object,

     Gtk.Builder,
     Gtk.Handlers,

     Pango.Font,

     Ada.Characters.handling;

with Ada.Text_IO;          use Ada.Text_IO;


package body aIDE.Palette.of_pragmas
is

   use Glib,
       Glib.Error,
       Glib.Object,

       Gtk.Builder,
       Gtk.Button,
       Gtk.Window;


   --  Events
   --

   procedure on_raw_source_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                           Self       : in     aIDE.Palette.of_pragmas.view)
   is
      pragma Unreferenced (the_Button);
      new_Source : constant AdaM.raw_Source.view := AdaM.raw_Source.new_Source;
   begin
      put_Line ("KKK KKK " & the_Button.get_Label);

      Self.Target.Name_is (the_Button.get_Label);
      Self.Top.Hide;

      Self.Invoked_by.freshen;
   end on_raw_source_Button_clicked;




   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Palette.of_pragmas.view);


   --  Forge
   --
   function to_source_entities_Palette return View
   is
      Self        : constant Palette.of_pragmas.view := new Palette.of_pragmas.item;

      the_Builder :          Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;         pragma Unreferenced (Result);

   begin
      gtk_New (the_Builder);

      Result := the_Builder.add_from_File ("glade/palette/pragmas_palette.glade", Error'Access);

      if Error /= null
      then
         Put_Line ("Error: 'adam.Palette.of_source_Entities' ~ " & Get_Message (Error));
         Error_Free (Error);
      end if;

      Self.Top                     := gtk_Window   (the_Builder.get_Object ("top_Window"));
      Self.new_type_Frame          := gtk_Frame    (the_Builder.get_Object ("new_type_Frame"));
      Self.raw_source_Button       := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
      Self.comment_Button          := gtk_Button   (the_Builder.get_Object ("comment_Button"));
      Self.enumeration_type_Button := gtk_Button   (the_Builder.get_Object ("new_enumeration_Button"));
      Self.close_Button            := gtk_Button   (the_Builder.get_Object ("close_Button"));

      for i in Self.kind_Buttons'Range
      loop
         declare
            use Ada.Characters.handling;
            button_Name : constant String := AdaM.a_Pragma.Kind'Image (i);
         begin
            Self.kind_Buttons (i) := gtk_Button (the_Builder.get_Object (to_Lower (button_Name) & "_Button"));

            Button_Callbacks.connect (Self.kind_Buttons (i),
                                      "clicked",
                                      on_raw_source_Button_clicked'Access,
                                      Self);

         end;
      end loop;


--           Self.all_calls_remote_Button         := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.assert_Button                        := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.assertion_policy_Button              := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.asynchronous_Button                  := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.atomic_Button                        := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.atomic_components_Button             := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.attach_handler_Button                := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.convention_Button                    := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.cpu_Button                           := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.default_storage_pool_Button          := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.detect_blocking_Button               := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.discard_names_Button                 := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.dispatching_domain_Button            := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.elaborate_Button                     := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.elaborate_all_Button                 := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.elaborate_body_Button                := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.export_Button                        := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.import_Button                        := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.independent_Button                   := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.independent_components_Button        := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.inline_Button                        := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.inspection_point_Button              := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.interrupt_handler_Button             := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.interrupt_priority_Button            := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.linker_options_Button                := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.list_Button                          := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.locking_policy_Button                := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.no_return_Button                     := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.normalize_scalars_Button             := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.optimize_Button                      := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.pack_Button                          := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.page_Button                          := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.partition_elaboration_policy_Button  := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.preelaborable_initialization_Button  := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.preelaborate_Button                  := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.priority_Button                     := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.priority_specific_dispatching_Button := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.profile_Button                       := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.pure_Button                          := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.queuing_policy_Button                := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.relative_deadline_Button             := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.remote_call_interface_Button         := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.remote_types_Button                  := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.restrictions_Button                  := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.reviewable_Button                    := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.shared_passive_Button               := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.storage_size_Button                  := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.suppress_Button                      := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.task_dispatching_policy_Button       := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.unchecked_union_Button               := gtk_Button   (the_Builder.get_Object ("raw_source_Button"));
--           Self.unsuppress_Button                    : gtk_Button;
--           Self.volatile_Button                      : gtk_Button;
--           Self.volatile_components_Button           : gtk_Button;
--           Self.assertion_policy_2_Button            : gtk_Button;






--        Button_Callbacks.connect (Self.raw_source_Button,
--                                  "clicked",
--                                  on_raw_source_Button_clicked'Access,
--                                  Self);


--        Self.Top.modify_Font (Font_Desc => Pango.Font.From_String ("Courier 10"));
--        Self.freshen;

      return Self;
   end to_source_entities_Palette;




   --  Attributes
   --

   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.Top);
   end top_Widget;



   procedure show (Self : in out Item;   Invoked_by   : in aIDE.Editor.view;
--                                           Target       : in AdaM.Source.Entities_view;
--                                           Target       : in AdaM.Entity.Entities_view;
                                         Target       : in AdaM.a_Pragma.view;
                   Allowed      : in Filter)
   is
   begin
      Self.Invoked_by := Invoked_by;
      Self.Target     := Target;

--        case Allowed
--        is
--           when declare_Region =>
--              Self.new_type_Frame.show;
--
--           when begin_Region =>
--              Self.new_type_Frame.hide;
--        end case;

      Self.Top.show;
   end show;


   procedure freshen (Self : in out Item)
   is
   begin
      null;
   end freshen;


end aIDE.Palette.of_pragmas;
