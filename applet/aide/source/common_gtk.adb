-----------------------------------------------------------------------
--          GtkAda - Ada95 binding for the Gimp Toolkit              --
--                                                                   --
--                     Copyright (C) 1998-1999                       --
--        Emmanuel Briot, Joel Brobecker and Arnaud Charlet          --
--                     Copyright (C) 2003-2006 AdaCore               --
--                                                                   --
-- This library is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This library is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this library; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-----------------------------------------------------------------------

with Gtk.Arguments;
with Gtk.Enums;            use Gtk.Enums;
with Ada.Strings.Fixed;


package body Common_Gtk
is


   procedure Page_Switch (Notebook    : access Gtk_Notebook_Record'Class;
                          old_page_Id,
                          new_page_Id : in     Gint)
   is
   begin
      if old_page_Id >= 0 then
         declare
            old_Page       : constant Gtk_Widget := Get_Nth_Page (Notebook, old_page_Id);
            old_page_Label : constant gtk_Label  := gtk_Label    (Notebook.Get_Tab_Label (old_Page));

            old_label_Text : constant String := old_page_Label.Get_Text;
         begin
            if         old_label_Text'Length  >= 3
              and then old_label_Text (1 .. 3) = "<b>"
            then
               old_page_Label.set_Markup (old_label_Text (4 .. old_label_Text'Last - 4));
            else
               old_page_Label.set_Markup (old_label_Text);
            end if;
         end;
      end if;

      if new_page_Id >= 0 then
         declare
            new_Page       : constant Gtk_Widget := Get_Nth_Page (Notebook, new_page_Id);
            new_page_Label : constant gtk_Label  := gtk_Label    (Notebook.Get_Tab_Label (new_Page));
         begin
            if new_page_Label /= null then
               new_page_Label.set_Markup ("<b>" & new_page_Label.Get_Text & "</b>");
            end if;
         end;
      end if;
   end Page_Switch;


   procedure Page_Switch (Notebook : access Gtk_Notebook_Record'Class;
                          Params   : in     Gtk.Arguments.Gtk_Args)
   is
      old_page_Id : constant Gint := Get_Current_Page (Notebook);
      new_page_Id : constant Gint := Gint (Gtk.Arguments.To_Guint (Params, 2));
   begin
      Page_Switch (Notebook,
                   old_page_Id, new_page_Id);
   end Page_Switch;




   procedure enable_bold_Tabs_for (the_Notebook : in gtk_Notebook)
   is
   begin
      Notebook_Cb.Connect (the_Notebook, "switch_page", Page_Switch'Access);

      Page_Switch (Notebook    => the_Notebook,
                   old_page_Id => Get_Current_Page (the_Notebook),
                   new_page_Id => Get_Current_Page (the_Notebook));
   end enable_bold_Tabs_for;


   -------------------------
   --  Build_Option_Menu  --
   -------------------------

--     procedure Build_Option_Menu
--       (Omenu   : out Gtk.Option_Menu.Gtk_Option_Menu;
--        Gr      : in out Widget_SList.GSlist;
--        Items   : Chars_Ptr_Array;
--        History : Gint;
--        Cb      : Widget_Handler.Marshallers.Void_Marshaller.Handler)
--
--     is
--        Menu      : Gtk_Menu;
--        Menu_Item : Gtk_Radio_Menu_Item;
--
--     begin
--        Gtk.Option_Menu.Gtk_New (Omenu);
--        Gtk_New (Menu);
--
--        for I in Items'Range loop
--           Gtk_New (Menu_Item, Gr, ICS.Value (Items (I)));
--           Widget_Handler.Object_Connect (Menu_Item, "activate",
--                                          Widget_Handler.To_Marshaller (Cb),
--                                          Slot_Object => Menu_Item);
--           Gr := Get_Group (Menu_Item);
--           Append (Menu, Menu_Item);
--           if Gint (I) = History then
--              Set_Active (Menu_Item, True);
--           end if;
--           Show (Menu_Item);
--        end loop;
--        Gtk.Option_Menu.Set_Menu (Omenu, Menu);
--        Gtk.Option_Menu.Set_History (Omenu, History);
--     end Build_Option_Menu;


   --------------------
   -- Destroy_Window --
   --------------------

   procedure Destroy_Window (Win : access Gtk.Window.Gtk_Window_Record'Class;
                             Ptr : in Gtk_Window_Access) is
      pragma Warnings (Off, Win);
   begin
      Ptr.all := null;
   end Destroy_Window;

   --------------------
   -- Destroy_Dialog --
   --------------------

   procedure Destroy_Dialog (Win : access Gtk.Dialog.Gtk_Dialog_Record'Class;
                             Ptr : in Gtk_Dialog_Access) is
      pragma Warnings (Off, Win);
   begin
      Ptr.all := null;
   end Destroy_Dialog;

   --------------
   -- Image_Of --
   --------------

   function Image_Of (I : in Gint) return String is
   begin
      return Ada.Strings.Fixed.Trim (Gint'Image (I), Ada.Strings.Left);
   end Image_Of;

end Common_Gtk;
