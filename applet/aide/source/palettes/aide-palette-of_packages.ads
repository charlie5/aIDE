with
     AdaM.context_Line,
     Gtk.Button,
     gtk.Widget;

private
with
     Gtk.gEntry,
     Gtk.Window,
     Gtk.Notebook,
     Gtk.Table;


package aIDE.Palette.of_packages
is

   type Item is new Palette.item with private;
   type View is access all Item'Class;


   --  Forge
   --
   function  to_packages_Palette return View;


   --  Attributes
   --
   function  top_Widget (Self : in     Item) return gtk.Widget.Gtk_Widget;


   --  Operations
   --
   procedure show      (Self : in out Item;   Invoked_by   : in     Gtk.Button.gtk_Button;
                                              Target       : in     adam.context_Line.view);
   procedure choice_is (Self : in out Item;   package_Name : in     String);
   procedure freshen   (Self : in out Item);



private

   use gtk.Window,
       gtk.Button,
       gtk.gEntry,
       gtk.Notebook,
       Gtk.Table;


   type Item is new Palette.item with
      record
         Invoked_by    : gtk_Button;
         Target        : adam.context_Line.view;

         recent_Table  : gtk_Table;
         top_Notebook,
         all_Notebook  : gtk_Notebook;

         Top           : gtk_Window;

         new_package_Entry : gtk_Entry;
         ok_Button         : gtk_Button;
         close_Button      : gtk_Button;
      end record;


   procedure build_recent_List (Self : in out Item);

end aIDE.Palette.of_packages;
