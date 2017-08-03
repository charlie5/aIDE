with
     Ada.Strings.unbounded,
     Ada.Strings.fixed;


package body AdaM.Assist
is

   function identifier_Suffix (Identifier : in String;   Count : in Positive) return String
   is
      use Ada.Strings,
          Ada.Strings.fixed,
          Ada.Strings.Unbounded;

      Dot   : Natural  := Index (Identifier, ".", Backward);
      Depth : Positive := 1;

--        First : Positive;
      Last  : Positive := Identifier'Last;

      Suffix : Text;

   begin
      while Depth <= Count
      loop
         if Dot = 0
         then
            insert (Suffix, 1, Identifier (Identifier'First .. Last));
            exit;
         end if;

         if Depth /= 1
         then
            insert (Suffix, 1, ".");
         end if;

         insert (Suffix, 1, Identifier (Dot + 1 .. Last));

         Last  := Dot - 1;
         Dot   := Index (Identifier, ".", from => Last, going => Backward);
         Depth := Depth + 1;
      end loop;

      return +Suffix;
   end identifier_Suffix;




   function Tail_of (the_full_Name : in String) return String
   is
      use Ada.Strings,
          Ada.Strings.fixed;

      Dot : constant Natural := Index (the_full_Name, ".", Backward);
   begin
      if Dot = 0
      then
         return the_full_Name;
      else
         return the_full_Name (Dot + 1 .. the_full_Name'Last);
      end if;
   end Tail_of;



   function strip_Tail_of (the_full_Name : in String) return String
   is
      use Ada.Strings,
          Ada.Strings.fixed;
      Dot : constant Natural := Index (the_full_Name, ".", Backward);
   begin
      if Dot = 0 then
         return the_full_Name;
      else
         return the_full_Name (the_full_Name'First .. Dot - 1);
      end if;
   end strip_Tail_of;



   function type_button_Name_of (the_full_Name : in String) return String
   is
      Tail : constant String := Assist.Tail_of (the_full_Name);
   begin
      if         the_full_Name'Length >= 9
        and then the_full_Name (the_full_Name'First .. the_full_Name'First + 8) = "Standard."
      then
         return Tail;
      end if;

      declare
         Head : constant String := assist.strip_Tail_of (the_full_Name);
      begin
         return assist.Tail_of (Head) & "." & Tail;
      end;
   end type_button_Name_of;



   function Split (the_Text : in String) return text_Lines
   is
      use ada.Strings.Fixed,
          ada.Strings.Unbounded;

      the_Lines : text_Lines;
      Dot       : Natural   := Index (the_Text, ".");
      First     : Positive  := 1;
      Last      : Positive;

   begin
      while Dot /= 0
      loop
         Last  := Dot - 1;
         the_Lines.append (+the_Text (First .. Last));
         First := Dot + 1;
         Dot   := Index (the_Text, ".", First);
      end loop;

      the_Lines.append (+the_Text (First .. the_Text'Last));
      return the_Lines;
   end Split;

end AdaM.Assist;
