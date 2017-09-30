with
     aIDE.Editor.of_comment,
     aIDE.Editor.of_exception,
     aIDE.Editor.of_pragma,
     aIDE.Editor.of_subtype,
     aIDE.Editor.of_enumeration_type,
     aIDE.Editor.of_signed_integer_type,
     aIDE.Editor.of_fixed_type,
     aIDE.Editor.of_float_type,
     aIDE.Editor.of_array_type,
     aIDE.Editor.of_subtype_indication,
     aIDE.Editor.of_object,
     aIDE.Editor.of_raw_source,

     AdaM.raw_Source,
     AdaM.Comment,
     AdaM.a_Pragma,
     AdaM.Declaration.of_exception,
     AdaM.Declaration.of_object,
     AdaM.a_Type.a_subtype,
     AdaM.a_Type.enumeration_type,
     AdaM.a_Type.signed_integer_type,
     AdaM.a_Type.ordinary_fixed_point_type,
     AdaM.a_Type.floating_point_type,
     AdaM.a_Type.array_type,
     AdaM.subtype_Indication,

     Ada.Tags;

with Ada.Text_IO; use Ada.Text_IO;


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

      elsif Target.all in AdaM.a_Pragma.item'Class
      then
         declare
            new_Editor : constant Editor.of_pragma.view := Editor.of_pragma.Forge.new_Editor (AdaM.a_Pragma.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in AdaM.Declaration.of_exception.item'Class
      then
         declare
            new_Editor : constant Editor.of_exception.view := Editor.of_exception.Forge.new_Editor (AdaM.Declaration.of_exception.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in AdaM.Declaration.of_object.item'Class
      then
         declare
            new_Editor : constant Editor.of_object.view := Editor.of_object.Forge.new_Editor (AdaM.Declaration.of_object.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in AdaM.a_Type.a_subtype.item'Class
      then
         declare
            new_Editor : constant Editor.of_subtype.view
              := Editor.of_subtype.Forge.to_Editor (AdaM.a_Type.a_subtype.view (Target));
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

      elsif Target.all in AdaM.a_Type.signed_integer_type.item'Class
      then
         declare
            new_Editor : constant Editor.of_signed_integer_type.view
              := Editor.of_signed_integer_type.Forge.to_Editor (AdaM.a_Type.signed_integer_type.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in AdaM.a_Type.ordinary_fixed_point_type.item'Class
      then
         declare
            new_Editor : constant Editor.of_fixed_type.view
              := Editor.of_fixed_type.Forge.to_Editor (AdaM.a_Type.ordinary_fixed_point_type.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in AdaM.a_Type.floating_point_type.item'Class
      then
         declare
            new_Editor : constant Editor.of_float_type.view
              := Editor.of_float_type.Forge.to_Editor (AdaM.a_Type.floating_point_type.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in AdaM.a_Type.array_type.item'Class
      then
         declare
            new_Editor : constant Editor.of_array_type.view
              := Editor.of_array_type.Forge.to_Editor (AdaM.a_Type.array_type.view (Target));
         begin
            Self := Editor.view (new_Editor);
         end;

      elsif Target.all in AdaM.subtype_Indication.item'Class
      then
         declare
            new_Editor : constant Editor.of_subtype_indication.view
              := Editor.of_subtype_indication.Forge.to_Editor (AdaM.subtype_Indication.view (Target));
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
