with
     aIDE.Editor.of_comment,
     aIDE.Editor.of_enumeration_type,
     aIDE.Editor.of_raw_source,
     AdaM.raw_Source,
     AdaM.Comment,
     AdaM.a_Type.enumeration_type,
     ada.Tags;
with Ada.Text_IO; use Ada.Text_IO;

--  with Ada.Text_IO; use Ada.Text_IO;


package body aIDE.Editor
is

--     function to_Editor (Target : in AdaM.Source.Entity_view) return Editor.view
   function to_Editor (Target : in AdaM.Entity.view) return Editor.view
   is
      use type AdaM.Entity.view;
      use -- AdaM.Source,
          AdaM.Comment;

      Self : Editor.view;
   begin
      if Target = null then raise Program_Error with "null Target"; end if;

      if Target.all in AdaM.raw_Source.item'Class
      then
         declare
            new_Editor : constant Editor.of_raw_source.view
              := Editor.of_raw_source.Forge.to_comment_Editor (AdaM.raw_Source.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in AdaM.Comment.item'Class
      then
         declare
            new_Editor : constant Editor.of_comment.view := Editor.of_comment.Forge.to_comment_Editor (AdaM.Comment.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in AdaM.a_Type.enumeration_type.item'Class
      then
         declare
            new_Editor : constant Editor.of_enumeration_type.view
              := Editor.of_enumeration_type.Forge.to_Editor (AdaM.a_Type.enumeration_type.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      else
         put_Line ("Warning: no editor is known for entity of type " & ada.Tags.Expanded_Name (Target.all'Tag));
         return null;
--           raise Program_Error with "no editor is known for entity of type " & ada.Tags.Expanded_Name (Target.all'Tag);
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
