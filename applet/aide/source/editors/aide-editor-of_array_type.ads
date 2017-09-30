with
     AdaM.a_Type.array_type,
     gtk.Widget;

private
with
     gtk.gEntry,
     gtk.Box,
     gtk.Label,
     gtk.Button;


package aIDE.Editor.of_array_type
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_Editor (the_Target : in AdaM.a_Type.array_type.view) return View;
   end Forge;

   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget;



private

   use gtk.Button,
       gtk.gEntry,
       gtk.Label,
       gtk.Box;


   type Item is new Editor.item with
      record
         Target               : AdaM.a_Type.array_type.view;

         top_Box              : gtk_Box;
         type_name_Entry      : Gtk_Entry;
         index_Box            : gtk_Box;
--           index_type_Button    : gtk_Button;
--           unconstrained_Label  : gtk_Label;
--           constrained_Label    : gtk_Label;
--           first_Entry          : Gtk_Entry;
--           last_Entry           : Gtk_Entry;
         element_type_Button  : gtk_Button;
         rid_Button           : gtk_Button;
      end record;


   overriding
   procedure freshen (Self : in out Item);

end aIDE.Editor.of_array_type;
