with
     adam.Context,
     gtk.Widget;

private
with
     gtk.Label,
     gtk.Frame,
     gtk.Box;


package aIDE.Editor.of_context
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_context_Editor (the_Context : in adam.Context.view) return View;
   end Forge;

   overriding
   function top_Widget  (Self : in Item) return gtk.Widget.Gtk_Widget;

   overriding
   procedure freshen    (Self : in out Item);

   procedure Context_is (Self : in out Item;   Now : in adam.Context.view);


private

   use gtk.Widget,
       gtk.Box,
       gtk.Label,
       gtk.Frame;


   type Item is new Editor.item with
      record
         Context           : adam.Context.view;

         Top               : Gtk_Frame;
         context_Label     : Gtk_Label;
         context_lines_Box : Gtk_Box;
      end record;

end aIDE.Editor.of_context;
