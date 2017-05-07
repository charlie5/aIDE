with
     adam.a_Type.enumeration_type,
     gtk.Widget;

private
with
     gtk.gEntry,
     gtk.Box,
     gtk.Label,
     gtk.Button;


package aIDE.Editor.of_enumeration_type
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_Editor (the_Target : in adam.a_Type.enumeration_type.view) return View;
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
         Target               : adam.a_Type.enumeration_type.view;

         top_Box              : gtk_Box;
         name_Entry           : Gtk_Entry;
         is_Label             : Gtk_Label;
         literals_Box         : gtk_Box;
         rid_Button           : gtk_Button;
      end record;


   overriding
   procedure freshen (Self : in out Item);

end aIDE.Editor.of_enumeration_type;
