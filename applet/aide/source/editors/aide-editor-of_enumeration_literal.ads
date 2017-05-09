with
     AdaM.a_Type.enumeration_literal,
     gtk.Widget;

private
with
     gtk.gEntry,
     gtk.Box,
     gtk.Button;

limited
with
     adam.a_Type.enumeration_type;


package aIDE.Editor.of_enumeration_literal
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   type enumeration_type_view is access all AdaM.a_Type.enumeration_type.item'Class;

   package Forge
   is
      function to_Editor (the_Target     : in AdaM.a_Type.enumeration_literal.view;
                          targets_Parent : in enumeration_type_view) return View;
   end Forge;

   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget;



private

   use gtk.Button,
       gtk.gEntry,
       gtk.Box;

   type Item is new Editor.item with
      record
         Target               : AdaM.a_Type.enumeration_literal.view;
         Targets_Parent       : enumeration_type_view;

         top_Box              : gtk_Box;
         name_Entry           : Gtk_Entry;
         rid_Button           : gtk_Button;
      end record;


end aIDE.Editor.of_enumeration_literal;
