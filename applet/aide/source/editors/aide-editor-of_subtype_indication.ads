with
     AdaM.subtype_Indication,
     gtk.Widget;

private
with
     gtk.gEntry,
     gtk.Box,
     gtk.Label,
     gtk.Button;


package aIDE.Editor.of_subtype_indication
is

   type Item is new Editor.item with private;
   type View is access all Item'Class;


   package Forge
   is
      function to_Editor (the_Target                : in AdaM.subtype_Indication.view;
                          is_in_unconstrained_Array : in Boolean) return View;
   end Forge;

   overriding
   function top_Widget (Self : in Item) return gtk.Widget.Gtk_Widget;



private

   use gtk.Button,
       gtk.gEntry,
       gtk.Label,
       gtk.Box;


   type Item is new Editor.item with
      record
         Target                    : AdaM.subtype_Indication.view;
         is_in_unconstrained_Array : Boolean := False;

         top_Box              : gtk_Box;
         type_Button          : gtk_Button;
         range_Label          : gtk_Label;
         unconstrained_Label  : gtk_Label;
         constrained_Label    : gtk_Label;
         first_Entry          : Gtk_Entry;
         last_Entry           : Gtk_Entry;
--           rid_Button           : gtk_Button;
      end record;


   overriding
   procedure freshen (Self : in out Item);

end aIDE.Editor.of_subtype_indication;
