with
     AdaM.context_Line,
     AdaM.a_Package,
     Gtk.Button,
     gtk.Widget,
     Ada.Streams;

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
                                              Target       : in     AdaM.context_Line.view);
   procedure choice_is (Self : in out Item;   package_Name : in String;
                                              the_Package  : in AdaM.a_Package.view);
   procedure freshen   (Self : in out Item);



   --  Recent Packages - ToDo: Refactor this out, if possible.
   --

   package recent_Packages
   is
      procedure register_Usage (package_Name : in AdaM.Text;
                                the_Package  : in AdaM.a_Package.view);
      function  fetch return AdaM.text_Lines;

      procedure register_Usage (the_Package : in AdaM.a_Package.view);
      function  fetch return AdaM.a_Package.vector;

      procedure read  (From : access Ada.Streams.Root_Stream_Type'Class);
      procedure write (To   : access Ada.Streams.Root_Stream_Type'Class);
   end recent_Packages;


private

   use gtk.Window,
       gtk.Button,
       gtk.gEntry,
       gtk.Notebook,
       Gtk.Table;


   type Item is new Palette.item with
      record
         Invoked_by    : gtk_Button;
         Target        : AdaM.context_Line.view;

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
