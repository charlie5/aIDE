with
     AdaM.a_Pragma,
     gtk.Widget;

private
with
     aIDE.Editor.of_block,
     aIDE.Editor.of_context,
     gtk.Box,
     gtk.Button,
     gtk.Frame,
     gtk.Label,
     gtk.Alignment,
     gtk.GEntry;


package aIDE.Editor.of_pragma
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function new_Editor (the_Pragma : in AdaM.a_Pragma.view) return View;
   end Forge;

   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget;

   function  Target    (Self : in     Item)     return AdaM.a_Pragma.view;
   procedure Target_is (Self : in out Item;   Now : in AdaM.a_Pragma.view);


private

   use gtk.Box,
       gtk.GEntry,
       gtk.Frame,
       gtk.Label,
       gtk.Button,
       gtk.Alignment;


   type Item is new Editor.item with
      record
         Target            : AdaM.a_Pragma.view;

         top_Frame         : Gtk_Frame;
         top_Box           : Gtk_Box;
         arguments_Box     : Gtk_Box;

--           context_Alignment : Gtk_Alignment;
--           context_Editor    : aIDE.Editor.of_context.view;

         open_parenthesis_Label  : Gtk_Label;
         close_parenthesis_Label : Gtk_Label;

--           name_Entry        : gtk_Entry;
         choose_Button        : gtk_Button;

--           block_Alignment   : Gtk_Alignment;
--           block_Editor      : aIDE.Editor.of_block.view;
      end record;


   overriding
   procedure freshen (Self : in out Item);

end aIDE.Editor.of_pragma;
