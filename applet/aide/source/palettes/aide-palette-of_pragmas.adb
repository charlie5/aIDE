with
     AdaM.Comment,
     AdaM.raw_Source,
     AdaM.a_Type.enumeration_type,

     Glib,
     Glib.Error,
     Glib.Object,

     Gtk.Builder,
     Gtk.Handlers,

     Pango.Font;

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
      Self.Target.append (new_Source.all'Access);
      Self.Top.Hide;

      Self.Invoked_by.freshen;
   end on_raw_source_Button_clicked;




   procedure on_comment_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                        Self       : in     aIDE.Palette.of_pragmas.view)
   is
      pragma Unreferenced (the_Button);
      new_Comment : constant AdaM.Comment.view := AdaM.Comment.new_Comment;
   begin
      Self.Target.append (new_Comment.all'Access);
      Self.Top.Hide;

      Self.Invoked_by.freshen;
   end on_comment_Button_clicked;



   procedure on_enumeration_type_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                                 Self       : in     aIDE.Palette.of_pragmas.view)
   is
      pragma Unreferenced (the_Button);
      new_Enumeration : constant AdaM.a_Type.enumeration_type.view := AdaM.a_Type.enumeration_type.new_Type ("");
   begin
      Self.Target.append (new_Enumeration.all'Access);
      Self.Top.Hide;

      Self.Invoked_by.freshen;
   end on_enumeration_type_Button_clicked;



   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Palette.of_pragmas.view);


   --  Forge
   --
   function to_source_entities_Palette return View
   is
      Self        : constant Palette.of_pragmas.view := new Palette.of_pragmas.item;

      the_Builder :          Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;
      pragma Unreferenced (Result);

   begin
      gtk_New (the_Builder);

      Result := the_Builder.add_from_File ("glade/palette/pragma_palette.glade", Error'Access);

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

      Button_Callbacks.connect (Self.raw_source_Button,
                                "clicked",
                                on_raw_source_Button_clicked'Access,
                                Self);

      Button_Callbacks.connect (Self.comment_Button,
                                "clicked",
                                on_comment_Button_clicked'Access,
                                Self);

      Button_Callbacks.connect (Self.enumeration_type_Button,
                                "clicked",
                                on_enumeration_type_Button_clicked'Access,
                                Self);


      Self.Top.modify_Font (Font_Desc => Pango.Font.From_String ("Courier 10"));
      Self.freshen;

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
                                         Target       : in AdaM.Entity.Entities_view;
                                         Allowed      : in Filter)
   is
   begin
      Self.Invoked_by := Invoked_by;
      Self.Target     := Target;

      case Allowed
      is
         when declare_Region =>
            Self.new_type_Frame.show;

         when begin_Region =>
            Self.new_type_Frame.hide;
      end case;

      Self.Top.show;
   end show;


   procedure freshen (Self : in out Item)
   is
   begin
      null;
   end freshen;


end aIDE.Palette.of_pragmas;
