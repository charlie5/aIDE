with
     adam.exception_Handler,
     gtk.Widget;

private
with
     gtk.Box,
     gtk.Frame,
     gtk.Alignment,
     gtk.Label,
     gtk.Button;

limited
with
     aIDE.Editor.of_block;


package aIDE.Editor.of_exception_handler
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   function  new_Editor (the_Handler : in     adam.exception_Handler.view) return View;
   procedure free       (the_Handler : in out View);


   overriding
   function  top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget;



private

   use Gtk.Box,
       Gtk.Button,
       Gtk.Alignment,
       Gtk.Label,
       Gtk.Frame;


   type Item is new Editor.item with
      record
         exception_Handler   : adam.exception_Handler.view;

         top_Frame           : gtk_Frame;
         top_Box             : gtk_Box;

         handler_Alignment   : Gtk_Alignment;
         block_Editor        : access aIDE.Editor.of_block.item'Class;

         when_Label          : gtk_Label;
         exception_names_Box : gtk_Box;

         rid_Button          : gtk_Button;
      end record;


   procedure add_new_exception_Button (Self : access Item;   Slot : in Positive);
   function  exception_Button         (Self : in     Item;   Slot : in Positive) return Gtk.Button.gtk_Button;

end aIDE.Editor.of_exception_handler;
