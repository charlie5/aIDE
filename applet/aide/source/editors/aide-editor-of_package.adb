with
     aIDE.GUI,
     aIDE.Style,
     AdaM.Assist;

with Ada.Text_IO;          use Ada.Text_IO;

with Glib;                 use Glib;
with Glib.Error;           use Glib.Error;
with Glib.Object;          use Glib.Object;

with Gtk.Box;              use Gtk.Box;
with Gtk.Builder;          use Gtk.Builder;
with Gtk.GEntry;           use Gtk.GEntry;
with Gtk.Handlers;
with Gtk.Text_View;        use Gtk.Text_View;

with Common_Gtk;           use Common_Gtk;
with Gtk.Alignment;        use Gtk.Alignment;



package body aIDE.Editor.of_package
is
   use Gtk.Widget;



   function on_name_Entry_leave (the_Entry : access Gtk_Entry_Record'Class;
                                 Self      : in     aIDE.Editor.of_package.view) return Boolean
   is
      the_Text : constant String := the_Entry.Get_Text;
   begin
      Self.my_Package.Name_is (AdaM.Identifier (the_Text));
      aIDE.GUI.update_selected_package_Name (String (Self.my_Package.full_Name));

      return False;
   end on_name_Entry_leave;


   package Entry_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Entry_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_package.view);



   function on_declarations_Label_clicked (the_Label : access Gtk_Label_Record'Class;
                                           Self      : in     aIDE.Editor.of_package.view) return Boolean
   is
--        the_Entity : adam.Source.Entity_View := adam.Declaration.new_Declaration ("new").all'Access;
   begin
      put_Line ("on_declarations_Label_clicked");

      aIDE.GUI.show_source_entities_Palette (Invoked_by => Self.all'Access,
                                             Target     => Self.my_Package.Children);   -- .public_Entities);
--        the_Declaration.Type_is (adam.Applet.fetch_Type ("Standard.Integer"));

--        Self.my_Package.add (the_Entity);
--        Self.freshen;

      return False;
   end on_declarations_Label_clicked;



   package Label_return_Callbacks is new Gtk.Handlers.User_Return_Callback (Gtk_Label_Record,
                                                                            Boolean,
                                                                            aIDE.Editor.of_package.view);



   package body Forge
   is
      function to_package_Editor (the_Package : in adam.a_Package.view) return View
      is
         Self : constant Editor.of_package.view := new Editor.of_package.item;

         the_Builder : Gtk_Builder;
         Error       : aliased  GError;
         Result      :          Guint;

      begin
         Self.my_Package  := the_Package;
--           Self.public_Part := public_Part;

         Gtk_New (the_Builder);

         Result := the_Builder.Add_From_File ("glade/editor/package_editor.glade", Error'Access);

         if Error /= null then
            Put_Line ("Error: adam.Editor.block ~ " & Get_Message (Error));
            Error_Free (Error);
         end if;

         Self.Notebook             := gtk_Notebook        (the_Builder.get_Object ("top_Notebook"));
         Self.top_Box              := gtk_Box             (the_Builder.get_Object ("top_Box"));

         Self. public_entities_Box := gtk_Box             (the_Builder.get_Object ("public_entities_Box"));
         Self.private_entities_Box := gtk_Box             (the_Builder.get_Object ("private_entities_Box"));

         Self. public_context_Alignment := gtk_Alignment  (the_Builder.get_Object ("public_context_Alignment"));
         Self.private_context_Alignment := gtk_Alignment  (the_Builder.get_Object ("private_context_Alignment"));

         Self.name_Entry          := gtk_Entry           (the_Builder.get_Object ("name_Entry"));

         Self.package_Label       := gtk_Label           (the_Builder.get_Object ("package_Label"));
         Self.declarations_Label  := gtk_Label           (the_Builder.get_Object ("declarations_Label"));

         Self.public_context_Editor := aIDE.Editor.of_context.Forge.to_context_Editor (Self.my_Package.Context);
         Self.public_context_Editor.top_Widget.Reparent (new_Parent => Self.public_context_Alignment);

         Self.private_context_Editor := aIDE.Editor.of_context.Forge.to_context_Editor (Self.my_Package.Context);
         Self.private_context_Editor.top_Widget.Reparent (new_Parent => Self.private_context_Alignment);

         Self.  declare_Text := Gtk_Text_View (the_Builder.get_Object (  "declare_Textview"));
         Self.    begin_Text := Gtk_Text_View (the_Builder.get_Object (    "begin_Textview"));
         Self.exception_Text := Gtk_Text_View (the_Builder.get_Object ("exception_Textview"));

         Entry_return_Callbacks.Connect (Self.name_Entry,
                                         "focus-out-event",
                                         on_name_Entry_leave'Access,
                                         Self);

         Label_return_Callbacks.Connect (Self.declarations_Label,
                                         "button-release-event",
                                         on_declarations_Label_clicked'Access,
                                         Self);

         Self.freshen;
         enable_bold_Tabs_for (Self.Notebook);

         return Self;
      end to_package_Editor;
   end Forge;



   procedure destroy_Widget (Widget : not null access Gtk.Widget.Gtk_Widget_Record'Class)
   is
   begin
      Widget.destroy;
   end destroy_Widget;



   overriding
   procedure freshen (Self : in out Item)
   is
      use AdaM.Assist;
   begin
      put_Line ("KKKKK " & (String (Self.my_Package.full_Name)));

      declare
         use AdaM;
         parent_Prefix : constant Identifier := strip_standard_Prefix (parent_Name (Self.my_Package.full_Name));
      begin
         put_Line ("Self.my_Package.full_Name = " & String (Self.my_Package.full_Name));
         put_Line ("parent_Name (Self.my_Package.full_Name) = " & String (parent_Name (Self.my_Package.full_Name)));
         put_Line ("parent_Prefix = " & String (parent_Prefix));

         if parent_Prefix = ""
         then
            Self.package_Label.set_Text ("package ");
         else
            Self.package_Label.set_Text ("package " & String (parent_Prefix) & ".");
         end if;

         Self.name_Entry.set_Text (String (Self.my_Package.Name));
      end;

      -- Destroy all prior entity widgets.
      --
      loop
         declare
            the_Child : constant gtk_Widget := Self.public_entities_Box.get_Child (0);
         begin
            exit when the_Child = null;
            the_Child.destroy;
         end;
      end loop;

      loop
         declare
            the_Child : constant gtk_Widget := Self.private_entities_Box.get_Child (0);
         begin
            exit when the_Child = null;
            the_Child.destroy;
         end;
      end loop;

      -- Create all entity widgets.
      --
      declare
--           the_Entities : constant access adam.Source.Entity_Vector := Self.my_Package.public_Entities;
         the_Entities : constant adam.Entity.Entities_view := Self.my_Package.Children;
         the_Entity   :          adam.Entity.view;
      begin
         for i in 1 .. Integer (the_Entities.Length)
         loop
            the_Entity := the_Entities.Element (i);

            declare
               the_Editor : constant aIDE.Editor.view := aIDE.Editor.to_Editor (the_Entity);
            begin
               if the_Editor /= null
               then
                  if the_Entity.is_Public
                  then
                     if the_Editor.top_Widget.Get_Parent = null
                     then
                        Self.public_entities_Box.pack_Start (the_Editor.top_Widget);
                     else
                        the_Editor.top_Widget.reparent (Self.public_entities_Box);
                     end if;
                  else
                     if the_Editor.top_Widget.Get_Parent = null
                     then
                        Self.private_entities_Box.pack_Start (the_Editor.top_Widget);
                     else
                        the_Editor.top_Widget.reparent (Self.private_entities_Box);
                     end if;
                  end if;
               end if;
            end;
         end loop;
      end;


--        aIDE.Style.apply_Css (Self.top_Widget);     -- TODO: This causes a truckload of gtk warnings.


      --  Operations
      --
--        declare
--           the_Operations : adam.Operation.Vector := Self.Class.Operations;
--        begin
--           loop
--              declare
--                 the_Child : gtk_Widget := Self.operations_Box.Get_Child (0);
--              begin
--                 exit when the_Child = null;
--                 the_Child.destroy;
--              end;
--           end loop;
--
--           for i in 1 .. Integer (the_Operations.Length)
--           loop
--              declare
--                 the_Operation        : adam.Operation       .view renames the_Operations.Element (i);
--                 the_operation_Editor : adam.Editor.operation.view :=      adam.Editor.operation.Forge.to_operation_Editor (the_Operation,
--                                                                                                                            Self.of_package);
--              begin
--                 the_operation_Editor.top_Widget.reparent (Self.operations_Box);
--              end;
--           end loop;
--        end;

   end freshen;



   function  my_Package (Self : in     Item)     return adam.a_Package.view
   is
   begin
      return Self.my_Package;
   end my_Package;



   procedure Package_is (Self : in out Item;   Now : in adam.a_Package.view)
   is
   begin
      Self.my_Package := Now;

      Self. public_context_Editor.Context_is (Self.my_Package.Context);
      Self.private_context_Editor.Context_is (Self.my_Package.Context);

      Self.freshen;
   end Package_is;




   overriding function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      return gtk.Widget.Gtk_Widget (Self.Notebook);
   end top_Widget;


end aIDE.Editor.of_package;
