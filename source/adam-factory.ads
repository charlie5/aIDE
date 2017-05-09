with
     AdaM.Any,

     ada.Streams,
     ada.Tags;

package AdaM.Factory
--
-- Provides persistent pointers.
--
--
-- Example:
--
--  package Subprogram
--  is
--     type Item is new Source.Entity with private;
--     type View is access all Item'Class;
--
--  private
--     ...
--
--     procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--                           Self   : in              View);
--
--     procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--                           Self   : out             View);
--
--     for View'write use View_write;
--     for View'read  use View_read;
--  end Subprogram;
--
--
-- package body Subprogram
-- is
--    record_Version  : constant                 := 1;
--    max_Subprograms : constant                 := 5_000;
--    null_Subprogram : constant Subprogram.item := (Source.Entity with others => <>);
--
--    package Pool is new adam.Factory.Pools (".adam-store",
--                                            "subprograms",
--                                            max_Subprograms,
--                                            record_Version,
--                                            Subprogram.item,
--                                            Subprogram.view,
--                                            null_Subprogram);
--
--     procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--                           Self   : in              View)
--                           renames Pool.View_write;
--
--     procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--                          Self   : out             View)
--                          renames Pool.View_read;
--  end Subprogram;
--
--
--  procedure Test
--  is
--     the_Subprogram : Subprogram.view;
--  begin
--     adam.Factory.open;
--
--     if first_Run then
--        the_Subprogram := Pool.new_Item;
--     else
--        Subprogram.view'read (any_Stream, the_Subprogram);
--     end if;
--
--     Subprogram.view'write (any_Stream, the_Subprogram);
--
--     adam.Factory.close;
--  end Test;
--
--
-- The new subprogram will persist and the_Subprogram pointer can be streamed.
--
is
   procedure open;
   procedure close;

   type Any_view is access all Any.Item'Class;

   function to_View (Id : in AdaM.Id;   Tag : in ada.Tags.Tag) return Any_view;


   generic
      storage_Folder : String;
      pool_Name      : String;
      max_Items      : Positive := 5_000;
      record_Version : Positive;

      type Item is new AdaM.Any.Item with private;
      type View is access all Item'Class;

      null_Item : Item;

   package Pools
   is
      function  to_View (Id   : in AdaM.Id) return View;
      function  to_Id   (From : in View)    return AdaM.Id;

      function  new_Item     return View;
      procedure free (Self : in out View);

      procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                            Self   : in              View);
      procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                            Self   : out             View);

      function  storage_record_Version return Positive;
   end Pools;


end AdaM.Factory;
