with
     aIDE.Palette.of_types,
     gtk.Widget;

private
with
     gtk.Frame,
     gtk.Scrolled_Window;

with Gtk.Box;
with Gtk.Button;
with Gtk.Notebook;


package aIDE.Palette.of_types_package
is

   type Item is new Palette.item with private;
   type View is access all Item'Class;


   function  to_types_Palette_package return View;

   function  new_Button (Named           : in String;
                        package_Name    : in String;
                        types_Palette   : in palette.of_types.view;
                         use_simple_Name : in Boolean) return Gtk.Button.gtk_Button;


   procedure Parent_is         (Self : in out Item;   Now : in aIDE.Palette.of_types.view);

   function  top_Widget        (Self : in     Item) return gtk.Widget.Gtk_Widget;
   function  children_Notebook (Self : in     Item) return gtk.Notebook.gtk_Notebook;

   procedure add_Type     (Self : access Item;   Named        : in String;
                                                      package_Name : in String);


private

   use --gtk.Window,
       gtk.Button,
       gtk.Box,
       gtk.Notebook,
       gtk.Frame,
       gtk.Scrolled_Window;


   type Item is new Palette.item with
      record
         Parent            : Palette.of_types.view;

         Top               : gtk_Frame;
         children_Notebook : gtk_Notebook;
         types_Box         : gtk_Box;
         types_Window      : Gtk_Scrolled_Window;
      end record;

end aIDE.Palette.of_types_package;
