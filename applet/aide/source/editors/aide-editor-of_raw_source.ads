with
     adam.raw_Source,
     gtk.Widget;

private
with
     gtk.Text_View,
     gtk.Frame,
     gtk.Button,
     gtk.Alignment;


package aIDE.Editor.of_raw_source
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_comment_Editor (the_Comment : in adam.raw_Source.view) return View;
   end Forge;

   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget;



private

   use gtk.Button,
       gtk.Text_View,
       gtk.Alignment,
       gtk.Frame;


   type Item is new Editor.item with
      record
         Comment              : adam.raw_Source.view;
         Top                  : gtk_Frame;

         comment_text_View    : gtk_Text_View;
         parameters_Alignment : Gtk_Alignment;

         rid_Button           : gtk_Button;

      end record;

end aIDE.Editor.of_raw_source;
