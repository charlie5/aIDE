with
     aIDE.Palette.of_exceptions,
     AdaM.a_Package,
     AdaM.Declaration.of_exception,
     gtk.Widget;

private
with
     gtk.Frame;

with Gtk.Box;
with Gtk.Button;
with Gtk.Notebook;


package aIDE.Palette.of_exceptions_subpackages
is

   type Item is new Palette.item with private;
   type View is access all Item'Class;


   function to_exceptions_Palette_package return View;

   function new_Button (Named           : in String;
                        package_Name    : in String;
                        exceptions_Palette   : in palette.of_exceptions.view;
                        use_simple_Name : in Boolean) return Gtk.Button.gtk_Button;


   procedure Parent_is         (Self : in out Item;   Now : in aIDE.Palette.of_exceptions.view);

   function  top_Widget        (Self : in     Item) return gtk.Widget.Gtk_Widget;
   function  children_Notebook (Self : in     Item) return gtk.Notebook.gtk_Notebook;

   procedure add_Exception     (Self : access Item;   Named        : in String;
                                                      package_Name : in String);

   procedure add_Exception     (Self : access Item;   the_Exception : in AdaM.Declaration.of_exception.view;
                                                      the_Package   : in AdaM.a_Package.view);


private

   use
       gtk.Button,
       gtk.Box,
       gtk.Notebook,
       gtk.Frame;

   type Item is new Palette.item with
      record
         Parent            : Palette.of_exceptions.view;

         Top               : gtk_Frame;
         children_Notebook : gtk_Notebook;
         exceptions_Box    : gtk_Box;
      end record;

end aIDE.Palette.of_exceptions_subpackages;
