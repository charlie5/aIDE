with
     AdaM.a_Type,
     AdaM.Environment;


package AdaM.Assist
is

   function known_Types       return AdaM.a_Type.Vector;
   function known_Environment return AdaM.Environment.item;


   function Tail_of             (the_full_Name : in String) return String;
   function strip_Tail_of       (the_full_Name : in String) return String;
   function type_button_Name_of (the_full_Name : in String) return String;

   function Split (the_Text : in String) return text_Lines;


end AdaM.Assist;
