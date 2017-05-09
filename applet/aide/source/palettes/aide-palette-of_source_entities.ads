with
     aIDE.Editor,
     AdaM.Source,

     Gtk.Widget,
     Gtk.Button,
     Gtk.Window;


package aIDE.Palette.of_source_entities
is

   type Item is new Palette.item with private;
   type View is access all Item'Class;


   --  Forge
   --
   function to_source_entities_Palette return View;


   --  Attributes
   --
   function  top_Widget (Self : in     Item) return gtk.Widget.Gtk_Widget;


   --  Operations
   --
   procedure show    (Self : in out Item;   Invoked_by   : in aIDE.Editor.view;
                                            Target       : in AdaM.Source.Entities_view);

   procedure freshen (Self : in out Item);



private

   use gtk.Window,
       gtk.Button;


   type Item is new Palette.item with
      record
         Invoked_by : aIDE.Editor.view;
         Target     : AdaM.Source.Entities_View;

         Top                     : gtk_Window;
         raw_source_Button       : Gtk_Button;
         comment_Button          : Gtk_Button;
         enumeration_type_Button : Gtk_Button;
         close_Button            : gtk_Button;
      end record;

end aIDE.Palette.of_source_entities;
