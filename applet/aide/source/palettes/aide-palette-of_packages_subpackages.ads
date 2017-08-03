with
     AdaM.a_Package,
     aIDE.Palette.of_packages,

     Gtk.Button,
     Gtk.Notebook,
     gtk.Widget;

private
with
     Gtk.Frame,
     Gtk.Box;


package aIDE.Palette.of_packages_subpackages
is

   type Item is new Palette.item with private;
   type View is access all Item'Class;


   function  to_packages_Palette_package return View;

   function  new_Button (for_Package      : in AdaM.a_Package.view;
                         Named            : in String;
                         packages_Palette : in Palette.of_packages.view) return Gtk.Button.gtk_Button;


   procedure Parent_is         (Self : in out Item;   Now : in aIDE.Palette.of_packages.view);

   function  top_Widget        (Self : in     Item) return gtk.Widget.Gtk_Widget;
   function  children_Notebook (Self : in     Item) return gtk.Notebook.gtk_Notebook;



private

   use
       gtk.Button,
       gtk.Box,
       gtk.Notebook,
       gtk.Frame;

   type Item is new Palette.item with
      record
         Parent            : Palette.of_packages.view;

         Top               : gtk_Frame;
         select_button_Box : gtk_Box;
         children_Notebook : gtk_Notebook;
      end record;

end aIDE.Palette.of_packages_subpackages;
