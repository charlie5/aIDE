
package AdaM.Assist
is

   function Tail_of             (the_full_Name : in String) return String;
   function strip_Tail_of       (the_full_Name : in String) return String;
   function type_button_Name_of (the_full_Name : in String) return String;

   function Split (the_Text : in String) return text_Lines;


   function identifier_Suffix     (Id : in Identifier;   Count : in Positive) return String;
   function strip_standard_Prefix (Id : in Identifier) return String;

   function  parent_Name (Id : in Identifier) return Identifier;
   function  simple_Name (Id : in Identifier) return Identifier;

   function  Split       (Id : in Identifier) return text_Lines;

end AdaM.Assist;
