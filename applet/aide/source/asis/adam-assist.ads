with
     adam.a_Type,
     adam.Environment;


package adam.Assist
is

   function known_Types       return adam.a_Type.Vector;
   function known_Environment return adam.Environment.item;


   function Tail_of             (the_full_Name : in String) return String;
   function strip_Tail_of       (the_full_Name : in String) return String;
   function type_button_Name_of (the_full_Name : in String) return String;

   function Split (the_Text : in String) return text_Lines;


end adam.Assist;
