with
     Ada.Text_IO;


package body Adam
is

   procedure put (the_Lines : in text_Lines)
   is
      use Ada.Text_IO;
   begin
      for i in 1 .. Integer (the_Lines.Length)
      loop
         put_Line (+the_Lines.Element (i));
      end loop;
   end put;

end Adam;
