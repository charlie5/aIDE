with
     aIDE.GUI,
     Shell,
     ada.Directories,
     ada.Characters.handling,
     ada.Strings.unbounded,
     ada.Text_IO;

package body aIDE
is

   procedure start
   is
   begin
      aIDE.GUI.open;
   end start;



   procedure stop
   is
   begin
      null;
   end stop;



   procedure build_Project
   is
      use aIDE.GUI,
          Shell,
          ada.Directories;

      project_Name          : constant String := "hello";
      generated_source_Path : constant String := "generated-source";
   begin
      clear_Log;

      log ("=======================");
      log ("=== Building Applet ===");
      log ("===                 ===");

      create_Path (generated_source_Path);


      --  Generate the main project file.
      --
      declare
         use ada.Characters.handling,
             ada.Strings.unbounded,
             ada.Text_IO;

         the_File     :          File_type;
         the_Filename : constant String   := to_Lower (project_Name) & ".gpr";

         procedure add (the_Line : in String)
         is
         begin
            put_Line (the_File, the_Line);
         end add;

      begin
         create (the_File,  out_File,  the_Filename);

         add ("project " & project_Name & " is");
         add ("");
         add ("   for Source_Dirs use (""" & generated_source_Path & """);");
         add ("   for Main use (""launch_hello.adb"");");
         add ("");
         add ("   for Object_Dir use ""build"";");
         add ("   for Exec_Dir   use ""."";");
         add ("");
         add ("   package Builder is");
         add ("      for Default_Switches (""ada"") use (""-g"", ""-j5"");");
         add ("   end Builder;");
         add ("");
         add ("end " & project_Name & ";");

         close (the_File);
      end;


      --  Build the applet.
      --
      declare
         use ada.Characters.Handling,
             ada.Strings.Unbounded,
             ada.Text_IO;

         the_Filename : constant String := to_Lower (project_Name) & ".gpr";
      begin
         log ("", 2);
         log ("Cleaning ...");
         log;
         log (command_Output (to_Command ("gnatclean -P " & the_Filename)));

         if Exists ("./build") then
            delete_Tree ("./build");     -- Clear the build folder.
         end if;

         create_Path ("./build");     --


         log ("", 2);
         log ("Compiling ...");
         log;
         log (command_Output (to_Command ("gprbuild -P " & the_Filename)));
      end;

      -- Launch the applet.
      --
      if Exists ("./launch_hello")
      then
         log ("", 2);
         log ("Launching ...");
         log;
         log (command_Output (to_Command ("./launch_hello")));
      end if;

   end build_Project;


end aIDE;
