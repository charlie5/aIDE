with
     Ada.Strings.unbounded,
     Ada.Containers.vectors;


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


   -- Identifiers
   --

   type Identifier is new String;

   function "+" (Id : in Identifier) return String
   is (String (Id));

   function "+" (the_String : in String) return Identifier
   is (Identifier (the_String));


   function "+" (the_Text : in Text) return Identifier
   is (Identifier (String' (+the_Text)));
--       renames ada.Strings.Unbounded.To_String;
--
--     function "+" (Id : in Identifier) return Text
--     is (
--       renames ada.Strings.Unbounded.To_Unbounded_String;




private

   for Id'Size use 32;
   null_Id : constant Id := Id'First;

end AdaM;
