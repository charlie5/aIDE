with
     Asis;


package adam.Assist.Query.find_All.context_Processing
is

   procedure Process_Context
     (The_Context : in Asis.Context;
      Trace       : in Boolean     := False);

   function Get_Unit_From_File_Name
     (Ada_File_Name : in String;
      The_Context   : in Asis.Context) return Asis.Compilation_Unit;

end adam.Assist.Query.find_All.context_Processing;
