with
     ada.Strings.Unbounded,
     ada.Containers.Vectors;


package AdaM
is

   --  Text
   --

   subtype Text is ada.Strings.Unbounded.Unbounded_String;

   function "+" (the_Text : in Text) return String
     renames ada.Strings.Unbounded.To_String;

   function "+" (the_String : in String) return Text
     renames ada.Strings.Unbounded.To_Unbounded_String;


   use type Text;
   package text_Vectors is new ada.Containers.Vectors (Positive, Text);
   subtype text_Lines   is     text_Vectors.Vector;

   procedure put (the_Lines : in text_Lines);


   --  Ids
   --

   type Id is range 0 .. 1_000_000;
   null_Id : constant Id;


   --  Exceptions
   --

   Error : exception;



private

   for Id'Size use 32;
   null_Id : constant Id := Id'First;

end AdaM;
