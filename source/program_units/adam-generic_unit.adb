with
     AdaM.Factory;


package body AdaM.generic_Unit
is

   --  Storage Pool
   --

   record_Version : constant := 1;
   pool_Size      : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "generic_units",
                                           pool_Size,
                                           record_Version,
                                           generic_Unit.item,
                                           generic_Unit.view);

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
      new_View : constant generic_Unit.view := Pool.new_Item;
   begin
      define (generic_Unit.item (new_View.all));
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out generic_Unit.view)
   is
   begin
      destruct (generic_Unit.item (Self.all));
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

end AdaM.generic_Unit;
