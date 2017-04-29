package aIDE.GUI
is

   procedure open;

   procedure clear_Log;
   procedure log (the_Message : in String   := "";
                  Count       : in Positive := 1);

end aIDE.GUI;
