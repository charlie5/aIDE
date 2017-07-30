with
     adam.a_Package,
     gtk.Widget;

private
with
     aIDE.Editor.context,
     gtk.Text_View,
     gtk.Alignment,
     gtk.gEntry,
     gtk.Label,
     gtk.Box;
with Gtk.Scrolled_Window;
with Gtk.Notebook;
with Gtk.Table;


package aIDE.Editor.of_package
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_package_Editor (the_Package : in adam.a_Package.view) return View;
   end Forge;

   overriding function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget;


   function  my_Package (Self : in     Item)     return adam.a_Package.view;
   procedure Package_is (Self : in out Item;   Now : in adam.a_Package.view);

   procedure freshen    (Self : in out Item);



private

   use gtk.Text_View,
       Gtk.scrolled_Window,
       gtk.Box,
       gtk.gEntry,
       gtk.Notebook,
       gtk.Table,
       gtk.Label,
       gtk.Alignment;


   type Item is new Editor.item with
      record
         my_Package         : adam.a_Package.view;

         Notebook           : gtk_Notebook;
         context_Editor     : aIDE.Editor.context.view;

         context_Alignment  : gtk_Alignment;
         name_Entry         : gtk_Entry;

         declarations_Label  : gtk_Label;
         simple_attributes_Table  : gtk_Table;

         top_Window         : gtk_scrolled_Window;
         top_Box            : gtk_Box;

         public_entities_Box : gtk_Box;

         declare_Text,
         begin_Text,
         exception_Text     : Gtk_Text_View;
      end record;


end aIDE.Editor.of_package;
