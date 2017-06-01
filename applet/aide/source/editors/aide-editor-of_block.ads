with
     AdaM.Entity,
     AdaM.Block,
     gtk.Widget;

private
with
     aIDE.Editor.of_exception_Handler,
     gtk.Text_View,
     gtk.Box,
     gtk.Label,
     gtk.Frame,
     gtk.Expander;


package aIDE.Editor.of_block
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_block_Editor (the_Block : in AdaM.Block.view) return View;
   end Forge;

   overriding
   function top_Widget (Self : in     Item) return gtk.Widget.Gtk_Widget;

   procedure Target_is (Self : in out Item;   Now : in AdaM.Block.view);
   function  Target    (Self : in     Item)     return AdaM.Block.view;



private

   use gtk.Text_View,
       gtk.Expander,
       gtk.Box,
       gtk.Label,
       gtk.Frame;


   type my_Expander_Record is new Gtk_Expander_Record with
      record
--           Target : AdaM.Source.Entities_View;
         Target : AdaM.Entity.Entities_View;
         Editor : aIDE.Editor.of_block.view;
      end record;

   type my_Expander is access all my_Expander_Record'Class;


   type Item is new Editor.item with
      record
         Block              : AdaM.Block.view;

         block_editor_Frame : Gtk_Frame;
         top_Box            : gtk_Box;

         declare_Label      : Gtk_Label;
         declare_Expander   : my_Expander;
         declare_Box        : gtk_Box;

         begin_Label        : Gtk_Label;
         begin_Expander     : my_Expander;
         begin_Box          : gtk_Box;

         exception_Label    : Gtk_Label;
         exception_Expander : my_Expander;
         exception_Box      : gtk_Box;

         begin_Text,
         exception_Text     : Gtk_Text_View;

         exception_Handler  : aIDE.Editor.of_exception_Handler.view;
      end record;


   overriding
   procedure freshen (Self : in out Item);

end aIDE.Editor.of_block;
