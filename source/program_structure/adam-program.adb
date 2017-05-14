with
     AdaM.Factory;


package body AdaM.Program
is

   --  Storage Pool
   --

   record_Version  : constant                := 1;
   max_Subprograms : constant                := 5_000;
   null_Subprogram : constant Program.item := (others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "programs",
                                           max_Subprograms,
                                           record_Version,
                                           Program.item,
                                           Program.view,
                                           null_Subprogram);

   --  Forge
   --

   procedure define (Self : in out Item)
   is
   begin
      null;
   end define;


   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;


   function new_Subprogram return View
   is
      new_View : constant Program.view := Pool.new_Item;
   begin
      define (Program.item (new_View.all));
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out Program.view)
   is
   begin
      destruct (Program.item (Self.all));
      Pool.free (Self);
   end free;



   --  Attributes
   --

   overriding
   function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.Program;
