with
     adam.Source,
     gtk.Widget;


package aIDE.Editor
is

   type Item is abstract tagged private;
   type View is access all Item'Class;


   function  to_Editor  (Target : in adam.Source.Entity_view) return Editor.view;

   function  top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget;
   procedure freshen    (Self : in out Item) is null;


private

   type Item is abstract tagged
      record
         null;
      end record;

end aIDE.Editor;
