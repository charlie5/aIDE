with
     adam.a_Type,
     gtk.Widget;

with Gtk.Button;
with Gtk.Window;
with Gtk.Notebook;
with Gtk.Table;


package aIDE.Palette.of_types
is

   type Item is new Palette.item with private;
   type View is access all Item'Class;


   --  Forge
   --
   function to_types_Palette --(the_Attribute : in adam.Attribute.view;
                              --the_Class     : in adam.Class.view)
                              return View;


   --  Attributes
   --
   function  top_Widget (Self : in     Item) return gtk.Widget.Gtk_Widget;


   --  Operations
   --
   procedure show (Self : in out Item;   Invoked_by   : in     gtk.Button.gtk_Button;
                                         Target       : access adam.a_Type.view);
   procedure choice_is  (Self : in out Item;   Now          : in     String;
                                               package_Name : in     String);
   procedure freshen    (Self : in out Item);


private

   use gtk.Window,
       gtk.Button,
       gtk.Notebook,
       Gtk.Table;


   type Item is new Palette.item with
      record
         Invoked_by    : gtk_Button;
         Target        : access adam.a_Type.view;

         recent_Table  : gtk_Table;
         top_Notebook,
         all_Notebook  : gtk_Notebook;

         Top           : gtk_Window;
         close_Button  : gtk_Button;
      end record;


   procedure build_recent_List (Self : in out Item);


end aIDE.Palette.of_types;
