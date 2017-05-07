with
     aIDE.Editor.of_comment,
     aIDE.Editor.of_enumeration_type,
     aIDE.Editor.of_raw_source,
     adam.raw_Source,
     adam.Comment,
     adam.a_Type.enumeration_type,
     ada.Tags;

with Ada.Text_IO; use Ada.Text_IO;


package body aIDE.Editor
is

   function to_Editor (Target : in adam.Source.Entity_view) return Editor.view
   is
      use adam.Source, adam.Comment;
      Self : Editor.view;
   begin
      if Target = null then raise Program_Error with "null Target"; end if;

      if Target.all in adam.raw_Source.item'Class
      then
         declare
            new_Editor : constant Editor.of_raw_source.view
              := Editor.of_raw_source.Forge.to_comment_Editor (adam.raw_Source.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in adam.Comment.item'Class
      then
         declare
            new_Editor : constant Editor.of_comment.view := Editor.of_comment.Forge.to_comment_Editor (adam.Comment.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in adam.a_Type.enumeration_type.item'Class
      then
         declare
            new_Editor : constant Editor.of_enumeration_type.view
              := Editor.of_enumeration_type.Forge.to_Editor (adam.a_Type.enumeration_type.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      else
         raise Program_Error with "no editor is known for entity of type " & ada.Tags.Expanded_Name (Target.all'Tag);
      end if;


      Self.top_Widget.show;

      return Self;
   end to_Editor;


   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget
   is
   begin
      raise Program_Error with "top_Widget must be overridden in subclass of aIDE.Editor";
      return null;
   end top_Widget;


end aIDE.Editor;
