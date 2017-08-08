
package AdaM.Assist
is

   function Tail_of             (the_full_Name : in String) return String;
   function strip_Tail_of       (the_full_Name : in String) return String;
   function type_button_Name_of (the_full_Name : in String) return String;

   function Split (the_Text : in String) return text_Lines;


   function identifier_Suffix     (Identifier : in String;   Count : in Positive) return String;
   function strip_standard_Prefix (Identifier : in String) return String;

end AdaM.Assist;
