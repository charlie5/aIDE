with
     AdaM.context_Line,
     AdaM.Context,
     gtk.Widget,
     gtk.Button;

private
with
     gtk.Check_Button,
     gtk.Box;


package aIDE.Editor.of_context_line
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_context_line_Editor (the_Context      : in AdaM.Context     .view;
                                       the_Context_Line : in AdaM.context_Line.view) return View;
   end Forge;

   overriding
   function top_Widget   (Self : in Item) return gtk.Widget.gtk_Widget;
   function name_Button  (Self : in Item) return gtk.Button.gtk_Button;

   function context_Line (Self : in Item) return AdaM.context_Line.view;



private

   use gtk.Check_Button,
       gtk.Button,
       gtk.Box;


   type Item is new Editor.item with
      record
         Context      : AdaM.Context     .view;
         context_Line : AdaM.context_Line.view;

         Top          : Gtk_Box;
         name_Button  : gtk_Button;
         used_Button  : gtk_Check_Button;
         rid_Button   : gtk_Button;
      end record;


end aIDE.Editor.of_context_line;
