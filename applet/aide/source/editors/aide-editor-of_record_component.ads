with
     AdaM.record_Component,
     gtk.Widget;

private
with
     gtk.gEntry,
     gtk.Box,
     gtk.Label,
     gtk.Button;


package aIDE.Editor.of_record_component
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function new_Editor (the_Target : in AdaM.record_Component.view) return View;
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
         Target            : AdaM.record_Component.view;

         top_Box           : gtk_Box;
         name_Entry        : Gtk_Entry;
         type_Button       : gtk_Button;
         colon_Label       : gtk_Label;
         aliased_Label     : gtk_Label;
         initializer_Label : gtk_Label;
         default_Entry : Gtk_Entry;
         rid_Button        : gtk_Button;
      end record;


   overriding
   procedure freshen (Self : in out Item);

end aIDE.Editor.of_record_component;
