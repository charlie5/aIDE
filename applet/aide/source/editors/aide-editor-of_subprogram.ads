with
     adam.Subprogram,
     gtk.Widget;

private
with
     aIDE.Editor.of_block,
     aIDE.Editor.of_context,
     gtk.Box,
     gtk.Label,
     gtk.Alignment,
     gtk.GEntry;


package aIDE.Editor.of_subprogram
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_subprogram_Editor (the_Subprogram : in adam.Subprogram.view) return View;
   end Forge;

   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget;

   function  Target    (Self : in     Item)     return adam.Subprogram.view;
   procedure Target_is (Self : in out Item;   Now : in adam.Subprogram.view);


private

   use gtk.Box,
       gtk.GEntry,
       gtk.Label,
       gtk.Alignment;


   type Item is new Editor.item with
      record
         Subprogram        : adam.Subprogram.view;   -- TODO: This should be called Target.

         top_Box           : Gtk_Box;

         context_Alignment : Gtk_Alignment;
         context_Editor    : aIDE.Editor.of_context.view;

         procedure_Label   : Gtk_Label;
         name_Entry        : gtk_Entry;

         block_Alignment   : Gtk_Alignment;
         block_Editor      : aIDE.Editor.of_block.view;
      end record;


   overriding
   procedure freshen (Self : in out Item);

end aIDE.Editor.of_subprogram;
