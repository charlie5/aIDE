with
     AdaM.Factory;


package body AdaM.protected_Entry
is

   --  Storage Pool
   --

   record_Version : constant := 1;
   pool_Size      : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "protected_Entries",
                                           pool_Size,
                                           record_Version,
                                           protected_Entry.item,
                                           protected_Entry.view);

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
      new_View : constant protected_Entry.view := Pool.new_Item;
   begin
      define (protected_Entry.item (new_View.all));
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out protected_Entry.view)
   is
   begin
      destruct (protected_Entry.item (Self.all));
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

end AdaM.protected_Entry;
