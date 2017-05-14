with
     gtk.Widget;

with Gtk.Button;
with Gtk.Window;
with Adam.exception_Handler;
with Gtk.Notebook;
with Gtk.Table;


package aIDE.Palette.of_exceptions
is

   type Item is new Palette.item with private;
   type View is access all Item'Class;


   --  Forge
   --
   function to_exceptions_Palette return View;


   --  Attributes
   --
   function  top_Widget (Self : in     Item) return gtk.Widget.Gtk_Widget;


   --  Operations
   --
   procedure show       (Self : in out Item;   Invoked_by : in Gtk.Button.gtk_Button;
                                               Target     : in adam.exception_Handler.view;
                                               Slot       : in Positive);

   procedure choice_is  (Self : in out Item;   Now          : in String;
                                               package_Name : in String);

   procedure freshen    (Self : in out Item);


private

   use gtk.Window,
       gtk.Button,
       gtk.Notebook,
       Gtk.Table;


   type Item is new Palette.item with
      record
         Invoked_by    : gtk_Button;
         Target        : adam.exception_Handler.view;
         Slot          : Positive;

         recent_Table  : gtk_Table;
         top_Notebook,
         all_Notebook  : gtk_Notebook;

         Top           : gtk_Window;
         delete_Button : gtk_Button;
         close_Button  : gtk_Button;
      end record;


   procedure build_recent_List (Self : in out Item);

end aIDE.Palette.of_exceptions;
