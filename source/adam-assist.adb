with
     Ada.Strings.unbounded,
     Ada.Strings.fixed;


package body AdaM.Assist
is

   function identifier_Suffix (Id : in Identifier;   Count : in Positive) return Identifier
   is
      use Ada.Strings,
          Ada.Strings.fixed,
          Ada.Strings.Unbounded;

      the_Id : constant String := String (Id);

      Dot    : Natural  := Index (the_Id, ".", Backward);
      Depth  : Positive := 1;
      Last   : Positive := Id'Last;
      Suffix : Text;

   begin
      while Depth <= Count
      loop
         if Dot = 0
         then
            insert (Suffix, 1, the_Id (the_Id'First .. Last));
            exit;
         end if;

         insert (Suffix, 1, the_Id (Dot + 1 .. Last));

         if Depth /= Count
         then
            insert (Suffix, 1, ".");
         end if;

         Last  := Dot - 1;
         Dot   := Index (the_Id, ".", from => Last, going => Backward);
         Depth := Depth + 1;
      end loop;

      return +Suffix;
   end identifier_Suffix;



--     function strip_standard_Prefix (Id : in Identifier) return Identifier
--     is
--        the_Id : constant String := String (Id);
--        Token  : constant String := "Standard.";
--     begin
--        if the_Id (the_Id'First .. the_Id'First + Token'Length - 1) = Token
--        then
--           return the_Id (the_Id'First + Token'Length .. the_Id'Last);
--        else
--           return the_Id;
--        end if;
--     end strip_standard_Prefix;


   function strip_standard_Prefix (Id : in Identifier) return Identifier
   is
      Token  : constant Identifier := "Standard.";
   begin
      if         Id'Length >= Token'Length
        and then Id (Id'First .. Id'First + Token'Length - 1) = Token
      then
         return Id (Id'First + Token'Length .. Id'Last);
      else
         return Id;
      end if;
   end strip_standard_Prefix;



   function Tail_of (the_full_Name : in Identifier) return Identifier
   is
      use Ada.Strings,
          Ada.Strings.fixed;

      Dot : constant Natural := Index (String (the_full_Name), ".", Backward);
   begin
      if Dot = 0
      then
         return the_full_Name;
      else
         return the_full_Name (Dot + 1 .. the_full_Name'Last);
      end if;
   end Tail_of;



   function strip_Tail_of (the_full_Name : in Identifier) return Identifier
   is
      use Ada.Strings,
          Ada.Strings.fixed;
      Dot : constant Natural := Index (String (the_full_Name), ".", Backward);
   begin
      if Dot = 0 then
         return the_full_Name;
      else
         return the_full_Name (the_full_Name'First .. Dot - 1);
      end if;
   end strip_Tail_of;



   function type_button_Name_of (the_full_Name : in Identifier) return String
   is
      Tail : constant Identifier := Assist.Tail_of (the_full_Name);
   begin
      if         the_full_Name'Length >= 9
        and then the_full_Name (the_full_Name'First .. the_full_Name'First + 8) = "Standard."
      then
         return String (Tail);
      end if;

      declare
         Head : constant Identifier := assist.strip_Tail_of (the_full_Name);
      begin
         return String (assist.Tail_of (Head) & "." & Tail);
      end;
   end type_button_Name_of;




   function parent_Name (Id : in Identifier) return Identifier
   is
      use Ada.Strings,
          Ada.Strings.fixed;
   begin
      if Id = "Standard"
      then
         return "";
      end if;

      declare
         the_Id : constant String  := String (Id);
         I      : constant Natural := Index (the_Id, ".", going => Backward);
      begin
         if I = 0
         then
            return "Standard";
         end if;

         return Identifier (the_Id (the_Id'First .. I - 1));
      end;
   end parent_Name;



   function simple_Name (Id : in Identifier) return Identifier
   is
      use Ada.Strings,
          Ada.Strings.fixed;

      I : constant Natural := Index (String (Id), ".", going => Backward);
   begin
      if I = 0
      then
         return Id;
      end if;

      return Id (I + 1 .. Id'Last);
   end simple_Name;





--     function Split (the_Text : in Identifier) return text_Lines
--     is
--        use ada.Strings.Fixed,
--            ada.Strings.Unbounded;
--
--        the_Lines : text_Lines;
--        Dot       : Natural   := Index (the_Text, ".");
--        First     : Positive  := 1;
--        Last      : Positive;
--
--     begin
--        while Dot /= 0
--        loop
--           Last  := Dot - 1;
--           the_Lines.append (+the_Text (First .. Last));
--           First := Dot + 1;
--           Dot   := Index (the_Text, ".", First);
--        end loop;
--
--        the_Lines.append (+the_Text (First .. the_Text'Last));
--        return the_Lines;
--     end Split;




   function Split (Id : in Identifier) return text_Lines
   is
      use Ada.Strings,
          Ada.Strings.fixed;

      the_Id : constant String := String (Id);

      First  : Natural := the_Id'First;
      Last   : Natural;

      I      : Natural;
      Lines  : text_Lines;
   begin
      loop
         I := Index (the_Id, ".", from => First);

         if I = 0
         then
            Last := the_Id'Last;
            Lines.append (+the_Id (First .. Last));
            exit;
         end if;

         Last  := I - 1;
         Lines.append (+the_Id (First .. Last));
         First := I + 1;
      end loop;

      return Lines;
   end Split;


end AdaM.Assist;
