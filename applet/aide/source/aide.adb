with
     aIDE.GUI,
     AdaM.Assist,

     Shell,

     ada.Directories,
     ada.Characters.handling,
     ada.Strings.unbounded,
     ada.Streams.Stream_IO,
     ada.Text_IO;

package body aIDE
is

   -- Applet State
   --
   first_Run : Boolean := False;


   procedure define
   is
      use ada.Directories;
   begin
      -- Restore the aIDE applets persistent state.
      --
      declare
         use Adam,
             ada.Streams.Stream_IO;

         the_File   : File_Type;
         the_Stream : Stream_Access;
      begin
         open (the_File, in_File, ".adam-store/aide.stream");

         the_Stream := Stream (the_File);

         adam.Environment.item'read (the_Stream, the_Environ);
         Subprogram.view      'read (the_Stream, the_selected_App);

         close (the_File);

      exception
         when ada.Streams.Stream_IO.Name_Error =>
            first_Run := True;

--              define_standard_Ada_Types;
--              the_Environ.print;

            the_selected_App := Subprogram.new_Subprogram (Name => "unnamed_Procedure");   -- Create initial test package.
      end;

      all_Apps.append (the_selected_App);
   end define;


   procedure destruct
   is
   begin
      -- Store the aIDE applets persistent state.
      --
      declare
         use Adam,
             ada.Streams.Stream_IO;

         the_File   : File_Type;
         the_Stream : Stream_Access;
      begin
         create (the_File, out_File, ".adam-store/aide.stream");

         the_Stream := Stream (the_File);

         adam.Environment.item'write (the_Stream, the_Environ);
         Subprogram.view      'write (the_Stream, the_selected_App);

         close (the_File);
      end;
   end destruct;



   procedure start
   is
   begin
      aIDE.define;
      aIDE.GUI.open;
   end start;


   procedure stop
   is
   begin
      aIDE.destruct;
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

      if Exists (generated_source_Path)
      then
         delete_Tree (generated_source_Path);     -- Clear the generated source folder.
      end if;

      create_Path (generated_source_Path);


      generate_Apps:
      begin
         log ("", 2);
         log ("Generating apps ... ");
         log;

         for Each of all_Apps
         loop
            declare
               the_App : constant adam.Subprogram.view := Each;
            begin
               log ("   ... " & the_App.Name);

               --  Generate the app body source.
               --
               declare
                  use ada.Characters.handling,
                      ada.Strings.unbounded,
                      ada.Text_IO;

                  the_File     :          File_type;
                  the_Filename : constant String   :=   generated_source_Path
                                                      & "/"
                                                      & to_Lower (the_App.Name) & ".adb";
                  the_Source   : constant adam.Text_Vectors.Vector := the_App.to_spec_Source;
               begin
                  create (the_File,  out_File,  the_Filename);

                  for Each of the_Source
                  loop
                     put_Line (the_File,
                               to_String (Each));
                  end loop;

                  close (the_File);
               end;
            end;
         end loop;
      end generate_Apps;


      --  Generate the main project file.
      --
      declare
         use ada.Characters.handling,
             ada.Strings.unbounded,
             ada.Text_IO;

         use type adam.Subprogram.view;

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

         add ("   for Main use (");
         for Each of all_Apps
         loop
            add ("        """ & to_Lower (Each.Name) & ".adb""");
            if Each /= all_Apps.last_Element
            then
               add (",");
            end if;
         end loop;
         add ("   );");

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

         if Exists ("./build")
         then
            delete_Tree ("./build");     -- Clear the build folder.
         end if;

         create_Path ("./build");


         log ("", 2);
         log ("Compiling ...");
         log;

--           declare
--              the_Command    : Shell.Command     := to_Command ("gprbuild -P " & the_Filename);
--              command_Result : String         := my_Command_Output (the_Command);
--  --              Process     :          Shell.Process;
--  --              out_Pipe    : Shell.Pipe;
--  --              err_Pipe    : Shell.Pipe;
--           begin
--  --              run (the_Command, Output => out_Pipe,
--  --                                Errors => err_Pipe);
--
--  --              run (the_Command, Pipeline => True);
--
--  --              log (command_Result.From_Out_Pipe.all);
--  --              log (command_Result.From_Err_Pipe.all);
--
--              log (command_Result);
--              log (Output_of      (the_Command));
--              log (Errors_of      (the_Command));
--           end;


         declare
            the_Command : constant Shell.Command         := to_Command ("gprbuild -P " & the_Filename);
            Results     : constant Shell.Command_Results := Results_of (the_Command);
         begin
            log (Output_of (Results));
            log (Errors_of (Results));
         end;
      end;


      -- Launch the applet.
      --
      declare
         use ada.Characters.handling;
      begin
         if Exists (to_Lower ("./" & all_Apps.Element (1).Name))
         then
            log ("", 2);
            log ("Launching ...");
            log;

            declare
               Output : constant String := command_Output (to_Command ("./" & to_Lower (all_Apps.Element (1).Name)));
            begin
               if Output = ""
               then
                  log ("<null output>");
               else
                  log (Output);
               end if;
            end;
         end if;
      end;

      log ("", 2);
      log ("===              ===");
      log ("=== Applet Built ===");
      log ("====================");
   end build_Project;


end aIDE;
