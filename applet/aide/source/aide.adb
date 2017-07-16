with
     Navigate,

     aIDE.GUI,
     aIDE.Palette.of_packages,

     AdaM.Entity,


--       AdaM.Assist,
     AdaM.compilation,
     AdaM.library_Item,
     AdaM.library_Unit,
     AdaM.library_Unit.a_body,
     AdaM.Partition,
     AdaM.Program,
     AdaM.program_Library,
     AdaM.program_Unit,
     AdaM.task_Unit,
     AdaM.protected_Unit,
     AdaM.protected_Entry,
     AdaM.generic_Unit,

     AdaM.Declaration.of_package,
     AdaM.Declaration.of_exception,
     AdaM.Declaration.of_generic,
     AdaM.Declaration.of_instantiation,
     AdaM.Declaration.of_type,
     AdaM.Declaration.of_subtype,
     AdaM.Declaration.of_object,
     AdaM.Declaration.of_subprogram,
     AdaM.Declaration.of_null_procedure,
     AdaM.Declaration.of_expression_function,
     AdaM.Declaration.of_renaming.a_generic,
     AdaM.Declaration.of_renaming.a_package,
     AdaM.Declaration.of_renaming.a_subprogram,

     AdaM.   package_Body,
     AdaM.subprogram_Body,
     AdaM.with_Clause,
     AdaM. use_Clause,
     AdaM. use_Clause.for_package,
     AdaM. use_Clause.for_type,
     AdaM.context_Clause,
     AdaM.context_Item,
     AdaM.body_Stub,

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


   procedure define_standard_Ada_Types
   is
      use Shell,
          ada.Text_IO;
   begin
      -- Build the standard ada tree file.
      --
      put_Line ("rm *.adt: "        & command_Output (to_Command ("rm ./*.adt")));
      put_Line ("gnatmake output: " & Command_Output (to_Command ("gnatmake -c -gnatc -gnatt ./assets/asis/all_standard_ada.adb")));

--        the_Environ := AdaM.Assist.known_Environment;
--        the_Environ.print;


--        the_entity_Environ := AdaM.Assist.known_Entities;
      the_entity_Environ := Navigate;
      the_entity_Environ.print_Entities;
   end define_standard_Ada_Types;



   procedure define
   is
      use ada.Directories;
   begin
      -- Restore the aIDE applets persistent state.
      --
      declare
         use AdaM,
             ada.Streams.Stream_IO;

         the_File   : File_Type;
         the_Stream : Stream_Access;
      begin
         open (the_File, in_File, ".adam-store/aide.stream");

         the_Stream := Stream (the_File);

         AdaM.Environment.item'read (the_Stream, the_Environ);
         AdaM.Environment.item'read (the_Stream, the_entity_Environ);

         Subprogram.view      'read (the_Stream, the_selected_App);
         Subprogram.Vector    'read (the_Stream, all_Apps);

         Palette.of_packages.recent_Packages.read (the_Stream);

         close (the_File);

      exception
         when ada.Streams.Stream_IO.Name_Error =>
            first_Run := True;

            define_standard_Ada_Types;

            the_selected_App := Subprogram.new_Subprogram (Name => anonymous_Procedure);   -- Create initial test precedure..
            all_Apps.append (the_selected_App);
      end;
   end define;


   procedure destruct
   is
   begin
      -- Store the aIDE applets persistent state.
      --
      declare
         use AdaM,
             ada.Streams.Stream_IO;

         the_File   : File_Type;
         the_Stream : Stream_Access;
      begin
         create (the_File, out_File, ".adam-store/aide.stream");

         the_Stream := Stream (the_File);

         AdaM.Environment.item'write (the_Stream, the_Environ);
         AdaM.Environment.item'write (the_Stream, the_entity_Environ);

         Subprogram.view      'write (the_Stream, the_selected_App);
         Subprogram.vector    'write (the_Stream, all_Apps);

         Palette.of_packages.recent_Packages.write (the_Stream);

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



   --  Apps
   --

   function fetch_App (Named : in String) return adam.Subprogram.view
   is
   begin
      for Each of all_Apps
      loop
         if Each.Name = Named
         then
            return Each;
         end if;
      end loop;

      return null;
   end fetch_App;



   procedure build_Project
   is
      use aIDE.GUI,
          Shell,
          ada.Directories;

      project_Name          : constant String := "hello";
      generated_source_Path : constant String := "generated-source";
   begin
      clear_Log;

      log ("========================");
      log ("=== Building Project ===");
      log ("===                  ===");

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
               the_App : constant AdaM.Subprogram.view := Each;
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
                  the_Source   : constant AdaM.Text_Vectors.Vector := the_App.to_Source;
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

         use type AdaM.Subprogram.view;

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

         declare
            the_Command : constant Shell.Command         := to_Command ("gprbuild -P " & the_Filename);
            Results     : constant Shell.Command_Results := Results_of (the_Command);
         begin
            log (Output_of (Results));
            log (Errors_of (Results));
         end;
      end;


      -- Launch the applets.
      --
      for Each of all_Apps
      loop
         declare
            use ada.Characters.handling;
            app_Filename : constant String := to_Lower ("./" & Each.Name);
         begin
            if Exists (app_Filename)
            then
               log ("", 2);
               log ("Launching '" & Each.Name & "' ...");
               log;

               declare
                  Output : constant String := command_Output (to_Command (app_Filename));
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
      end loop;


      log ("", 2);
      log ("===               ===");
      log ("=== Project Built ===");
      log ("=====================");
   end build_Project;


end aIDE;
