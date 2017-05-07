with
     adam.Comment,
     adam.raw_Source,
     adam.a_Type.enumeration_type,

     Glib,
     Glib.Error,
     Glib.Object,

     Gtk.Builder,
     Gtk.Handlers,

     Pango.Font;

with Ada.Text_IO;          use Ada.Text_IO;


package body aIDE.Palette.of_source_entities
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
                                           Self       : in     aIDE.Palette.of_source_entities.view)
   is
      new_Source : constant adam.raw_Source.view := adam.raw_Source.new_Source;
   begin
      Self.Target.append (new_Source.all'Access);
      Self.Top.Hide;

      Self.Invoked_by.freshen;
   end on_raw_source_Button_clicked;




   procedure on_comment_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                        Self       : in     aIDE.Palette.of_source_entities.view)
   is
      new_Comment : constant adam.Comment.view := adam.Comment.new_Comment;
   begin
      Self.Target.append (new_Comment.all'Access);
      Self.Top.Hide;

      Self.Invoked_by.freshen;
   end on_comment_Button_clicked;



   procedure on_enumeration_type_Button_clicked (the_Button : access Gtk_Button_Record'Class;
                                                 Self       : in     aIDE.Palette.of_source_entities.view)
   is
      new_Enumeration : constant adam.a_Type.enumeration_type.view := adam.a_Type.enumeration_type.new_Type ("");
   begin
      Self.Target.append (new_Enumeration.all'Access);
      Self.Top.Hide;

      Self.Invoked_by.freshen;
   end on_enumeration_type_Button_clicked;



   package Button_Callbacks is new Gtk.Handlers.User_Callback (Gtk_Button_Record,
                                                               aIDE.Palette.of_source_entities.view);


   --  Forge
   --
   function to_source_entities_Palette return View
   is
      Self        : constant Palette.of_source_entities.view := new Palette.of_source_entities.item;

      the_Builder :          Gtk_Builder;
      Error       : aliased  GError;
      Result      :          Guint;

   begin
      gtk_New (the_Builder);

      Result := the_Builder.add_from_File ("glade/source_entity_options.glade", Error'Access);

      if Error /= null
      then
         Put_Line ("Error: 'adam.Palette.of_source_Entities' ~ " & Get_Message (Error));
         Error_Free (Error);
      end if;

      Self.Top                     := gtk_Window   (the_Builder.get_Object ("top_Window"));
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
                                         Target       : in adam.Source.Entities_view)
   is
   begin
      Self.Invoked_by := Invoked_by;
      Self.Target     := Target;

      Self.Top.show_All;
   end show;


   procedure freshen (Self : in out Item)
   is
   begin
      null;
   end freshen;


end aIDE.Palette.of_source_entities;
