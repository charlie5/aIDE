with
     AdaM.a_Type.signed_integer_type,
     gtk.Widget;

private
with
     gtk.gEntry,
     gtk.Box,
     gtk.Label,
     gtk.Button;


package aIDE.Editor.of_signed_integer_type
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_Editor (the_Target : in AdaM.a_Type.signed_integer_type.view) return View;
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
         Target               : AdaM.a_Type.signed_integer_type.view;

         top_Box              : gtk_Box;
         name_Entry           : Gtk_Entry;
         first_Entry          : Gtk_Entry;
         last_Entry           : Gtk_Entry;
         rid_Button           : gtk_Button;
      end record;


   overriding
   procedure freshen (Self : in out Item);

end aIDE.Editor.of_signed_integer_type;
